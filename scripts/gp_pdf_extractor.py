import pdfplumber
import re
import pandas as pd
from datetime import datetime
import sys

# AUTHOR: Simon Rosen

# -----------------------------------
#            DEPENDENCIES
#  This module requires 'pdfplumber'
#
#  Install: pip install pdfplumber
# -----------------------------------


def extract_data(file_path):
    pdfp_obj = pdfplumber.open(file_path)

    # Helper functions
    # text - string you are finding substring in
    def get_string_between_2_strings(text, string1, string2):
        # print("text: {}\n string1: {}, string2:{}".format("text", string1, string2))
        try:
            regex_str = string1 + '(.+?)' + string2
            # print('regex_str: {}'.format(regex_str))
            #         all_found = [x.group() for x in re.finditer(regex_str, text)]
            all_found = re.search(regex_str, text, re.DOTALL).group(1)
            # print(all_found)
        except AttributeError:
            # no text found between two substrings
            # print('Not found')
            all_found = []  # apply your error handling
        return all_found

    # GP data contained in paragraph under following heading
    # GAUTENG CONFIRMED COVID-19 CASES DISTRICT BREAKDOWN
    # GP cases, recoveries, deaths, contacts traced, people de-isolated & hospitalisations
    def get_gp_breakdown_data():
        district_pg =0
        first_page_txt = pdfp_obj.pages[0].extract_text()
        # GAUTENG CONFIRMED COVID-19 CASES DISTRICT BREAKDOWN
        heading_txt_1 = "GAUTENG CONFIRMED COVID-19 CASES DISTRICT BREAKDOWN"
        heading_txt_2 = "BREAKDOWN PER DISTRICT"
        breakdown_txt = get_string_between_2_strings(first_page_txt, heading_txt_1, heading_txt_2)
        if len(breakdown_txt)==0:
            breakdown_txt = get_string_between_2_strings(pdfp_obj.pages[1].extract_text(), heading_txt_1, heading_txt_2)
            district_pg=1
        if len(breakdown_txt)==0:
            breakdown_txt = get_string_between_2_strings(pdfp_obj.pages[1].extract_text(), "^", heading_txt_2)
            district_pg=1
        if len(breakdown_txt)==0:
            breakdown_txt = get_string_between_2_strings(first_page_txt, "^", ".*private facilities.*")            
        str_list = list(filter(lambda x: False if x == ' ' else True, breakdown_txt.splitlines()))
        str_body = "".join(str_list)
        sentences = str_body.split('.')

        def find_date(text):
            return re.search(r'(\d{2}|\d{1}) +[a-zA-Z]* +\d{4}', text).group(0)

        def get_nums(text, exclude_texts=['COVID-19']):
            for exclude_text in exclude_texts:
                text = text.replace(exclude_text, '')
            num_tuples = re.findall(r'(\d{3}|\d{2}|\d{1})( \d{3}|\d{2}|\d{1})*', text)
            num_list = [int(x[0] + x[1].replace(' ', '')) for x in num_tuples]
            return num_list

        date_txt = re.sub("\n"," ",get_string_between_2_strings(pdfp_obj.pages[0].extract_text(), heading_txt_1, "$"))
        
        sentences = "".join(date_txt).split(".")


        _gp_covid_stats = {"date": find_date(date_txt)}        


        # First Sentence
        tmp_dict = dict(zip(['cases', 'recoveries', 'deaths'], get_nums(sentences[0])[2:]))
        _gp_covid_stats.update(tmp_dict)

        # Second Sentence
        tmp_dict = dict(zip(['traced', 'de_isolated'], get_nums(sentences[1])[:2]))
        _gp_covid_stats.update(tmp_dict)

        # Third Sentence
        #tmp_dict = dict(zip(['hospitalised'], get_nums(sentences[2])))
        #_gp_covid_stats.update(tmp_dict)
        m=re.search(r".*total number of (\d+) people are currently.*hospi",breakdown_txt,re.S)
        _gp_covid_stats['hospitalised']=m.group(1)

        
        return district_pg, _gp_covid_stats


    district_pg, gp_covid_stats = get_gp_breakdown_data()

    # DISTRICT BREAKDOWN
    def get_district_data():
        district_table_list = pdfp_obj.pages[district_pg].extract_tables()[0]
        dl = []
        for i, row in enumerate(district_table_list):
            dl.append(list(filter(lambda x: x != None and len(x) !=0, row)))
        dl[-2]=dl[-2]+[0,0,0]
        all_list = [[x[i] for x in dl] for i in range(0, len(dl[0]))]
        gp_breakdown_dict = {curr_list[0]: curr_list[1:] for curr_list in all_list}
        gp_breakdown_df = pd.DataFrame.from_dict(gp_breakdown_dict)
        gp_breakdown_df.fillna(0, inplace=True)
        gp_breakdown_df.set_index("DISTRICT", inplace=True)
        gp_breakdown_df.rename(inplace=True, columns={gp_breakdown_df.columns[0]: "CASES",
                                                      gp_breakdown_df.columns[1]: "NEW CASES"})
        for i in range(0, 4):
            gp_breakdown_df.iloc[:, i] = gp_breakdown_df.iloc[:, i].apply(lambda x: x if type(x)==int else x.replace(' ', ''))
        return gp_breakdown_df

    gp_district_df = get_district_data()

    # ---------------
    #  SUB-DISTRICTS
    # ---------------

    def get_extracted_raw_list(page_no):
        currPage = pdfp_obj.pages[page_no]
        bounding_box = (300, 0, currPage.width, currPage.height)
        cropped_page = currPage.crop(bounding_box)
        # table_settings = {"vertical_strategy": "text"}
        table_settings = {"vertical_strategy":"lines_strict", "horizontal_strategy":"lines_strict", "snap_tolerance": 10, "join_tolerance": 15}
        extracted_raw_list = cropped_page.extract_tables(table_settings)[0]
        return list(filter(lambda x:x[-1] == '12628', extracted_raw_list))

    def get_sub_districts_data(rl):
        if rl == []: return []
        sub_districts_list = []
        curr_sub_district = []
        prev_sub_district = []
        raw_list=[rl[0]]
        i=1
        while i<len(rl):
            (curr_name,cases,recs)=rl[i]
            if cases in ['',None] or recs in['',None]:
                i=i+1
                if not cases: cases=rl[i][1]
                if not recs: recs=rl[i][2]
            raw_list.append((curr_name,cases,recs))
            i=i+1
            while i<len(rl) and (rl[i][0]==None or not re.search("City|Ekurhuleni|Unallocated|Lesedi|Emfuleni|Midvaal|Mogale|Rand West|Merafong",rl[i][0])):
                i=i+1
        for i in range(1, len(raw_list)):
            curr_list = raw_list[i]
            if curr_sub_district == [] or not (curr_list[0] == None or curr_list[0] == ''):
                if prev_sub_district != []:
                    sub_districts_list.append(curr_sub_district)

                curr_sub_district = curr_list
                prev_sub_district = curr_sub_district


            if (curr_sub_district[1] == '' and curr_list[1] != '' and curr_list[1] != None):
                curr_sub_district[1] = curr_list[1]

            if (curr_sub_district[2] == '' and curr_list[2] != '' and curr_list[2] != None):
                curr_sub_district[2] = curr_list[2]

            if (i == len(raw_list) - 1):
                sub_districts_list.append(curr_sub_district)

        # Check if first item of list is valid e.g. total and/or recoveries has values
        prev_sub_district = sub_districts_list[0]
        if (prev_sub_district[1] == '' or prev_sub_district[1] == None) and (prev_sub_district[2] == '' or \
                                                                             prev_sub_district[2] == None):
            sub_districts_list.pop(0)
        return sub_districts_list

    def get_table_list(page_no):
        currPage = pdfp_obj.pages[page_no]
        bounding_box = (300, 0, currPage.width, currPage.height)
        cropped_page = currPage.crop(bounding_box)
        # table_settings = {"vertical_strategy": "text"}
        table_settings = {"snap_tolerance": 10, "join_tolerance": 15}
        the_crop = cropped_page.extract_tables(table_settings)
        if the_crop in [[], None]:
            the_crop= cropped_page.extract_tables(table_settings)
        if the_crop in [[], None]: return []
        extracted_raw_list = the_crop[0]
        extracted_raw_list = list(filter(lambda y:y[-1]!=None or y[0]=="Ekurhuleni North 2",extracted_raw_list))
        return extracted_raw_list

    def get_all_sub_districts(page_start, page_end):
        all_sub_districts = []
        for i in range(page_start, page_end + 1):
            all_sub_districts.extend(get_sub_districts_data(get_table_list(i)))

        def remove_spaces(str_no):
            if type(str_no)==str:
                return str_no.replace(" ", "")
            else:
                return str_no

        all_sub_districts = [[x[0], remove_spaces(x[1]), remove_spaces(x[2])] for x in all_sub_districts]

        return all_sub_districts


    def get_district_map():
        # Johannesburg
        jhb_dict = dict(zip(['A', 'B', 'C', 'D', 'E', 'F', 'G', 'Unallocated'],
                            [[x[1], x[2]] for x in all_sub_dists[0:8]]))
        # Tshwane
        tsh_keys = list(range(1, 8))
        tsh_keys.append('Unallocated')
        tsh_dict = dict(zip(tsh_keys, [[x[1], x[2]] for x in all_sub_dists[8:16]]))

        
        # Ekurhuleni
        eku_keys = "e1 e2 n1 n2 s1 s2 Unallocated".split(" ")
        eku_dict = dict(zip(eku_keys, [[x[1], x[2]] for x in all_sub_dists[16:23]]))

        print(all_sub_dists[16:23])

        

        # Sedibeng
        sed_keys = "Emfuleni Lesedi Midvaal Unallocated".split(" ")
        sed_dict = dict(zip(sed_keys, [[x[1], x[2]] for x in all_sub_dists[22:26]]))

        # West Rand
        wr_keys = "Merafong Mogale Rand_West Unallocated".split(" ")
        wr_dict = dict(zip(wr_keys, [[x[1], x[2]] for x in all_sub_dists[26:30]]))

        # All Districts
        district_map = {
            'Johannesburg': jhb_dict,
            'Tshwane': tsh_dict,
            'Ekurhuleni': eku_dict,
            'Sedibeng': sed_dict,
            'West Rand': wr_dict
        }
        return district_map

    
    all_sub_dists = get_all_sub_districts(district_pg+1, district_pg+4)



    pdfp_obj.close()


    district_map = get_district_map()

    # DATE
    curr_date = datetime.strptime(gp_covid_stats['date'], '%d %B %Y')
    date_formatted = datetime.strftime(curr_date, '%d-%m-%Y')
    date_yyyymmdd = datetime.strftime(curr_date, '%Y%m%d')
    # print(gp_covid_stats['date'], date_formatted, date_yyyymmdd)

    ##############################
    #           OUT LIST         #
    # DETERMINES ORDER OF OUTPUT #
    ##############################

    # List later gets converted to formatted string

    jhb_districts = [x for x in 'ABCDEFG']+['Unallocated']
    tsh_districts = [x for x in range(1,8)]+['Unallocated']
    wr_districts=['Mogale',"Rand_West","Merafong","Unallocated"]
    
    out_list = [
        # Date
        date_yyyymmdd, date_formatted,

        # Gauteng Data
        gp_covid_stats['cases'], 'Check', 'Check','Check',
        gp_covid_stats['recoveries'], gp_covid_stats['deaths'], 'Check','Check',
        gp_covid_stats['hospitalised'],'Check',

        #  DISTRICT TOTALS DATA
        # ----------------------

        # Johannesburg
        gp_district_df.loc['Johannesburg']['CASES'],
        gp_district_df.loc['Ekurhuleni']['CASES'],
        gp_district_df.loc['Tshwane']['CASES'],
        gp_district_df.loc['Sedibeng']['CASES'],
        gp_district_df.loc['West Rand']['CASES'],
        gp_district_df.loc['Unallocated']['CASES'],
        ' Check',
        gp_district_df.loc['Johannesburg']['DEATHS'],
        gp_district_df.loc['Ekurhuleni']['DEATHS'],
        gp_district_df.loc['Tshwane']['DEATHS'],
        gp_district_df.loc['Sedibeng']['DEATHS'],
        gp_district_df.loc['West Rand']['DEATHS'],
        gp_district_df.loc['Unallocated']['DEATHS'],        
        
        gp_district_df.loc['Johannesburg']['RECOVERIES'],
        gp_district_df.loc['Ekurhuleni']['RECOVERIES'],
        gp_district_df.loc['Tshwane']['RECOVERIES'],
        gp_district_df.loc['Sedibeng']['RECOVERIES'],
        gp_district_df.loc['West Rand']['RECOVERIES'],
        gp_district_df.loc['Unallocated']['RECOVERIES'],        
        ' Check', ' Check'] + \
        [district_map['Johannesburg'][x][0] for x in jhb_districts]+\
        ['Check']+\
        [district_map['Johannesburg'][x][1] for x in jhb_districts]+\
        ['Check']+\
        [district_map['Tshwane'][x][0] for x in tsh_districts]+\
        ['Check']+\
        [district_map['Tshwane'][x][1] for x in tsh_districts]+\
        ['Check']+\
        [district_map['Ekurhuleni'][x][0] for x in ['e1','e2','n1','n2','s1','s2','Unallocated']]+\
        ['Check']+\
        [district_map['Ekurhuleni'][x][1] for x in ['e1','e2','n1','n2','s1','s2','Unallocated']]+\
        ['Check']+\
        [district_map['Sedibeng'][x][0] for x in ['Lesedi','Emfuleni','Midvaal','Unallocated']]+\
        ['Check']+\
        [district_map['Sedibeng'][x][1] for x in ['Lesedi','Emfuleni','Midvaal']]+\
        ['Check']+\
        [district_map['West Rand'][x][0] for x in wr_districts]+\
        ['Check']+\
        [district_map['West Rand'][x][1] for x in wr_districts]+\
        ['Check']


    def list_to_formatted(in_list, delimiter='\t'):
        return delimiter.join(map(str, in_list))

    out_str = list_to_formatted(out_list)
    # return district_map
    return out_str


if __name__ == "__main__":
    print(extract_data(sys.argv[1]))
