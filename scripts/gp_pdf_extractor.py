import pdfplumber
import re
import pandas as pd
from datetime import datetime

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
        first_page_txt = pdfp_obj.pages[0].extract_text()
        # GAUTENG CONFIRMED COVID-19 CASES DISTRICT BREAKDOWN
        heading_txt_1 = "GAUTENG CONFIRMED COVID-19 CASES DISTRICT BREAKDOWN"
        heading_txt_2 = "BREAKDOWN PER DISTRICT"
        breakdown_txt = get_string_between_2_strings(first_page_txt, heading_txt_1, heading_txt_2)

        str_list = list(filter(lambda x: False if x == ' ' else True, breakdown_txt.splitlines()))
        str_body = "".join(str_list)
        sentences = str_body.split('.')

        def find_date(text):
            return re.search(r'(\d{2}|\d{1}) [a-zA-Z]* \d{4}', text).group(0)

        def get_nums(text, exclude_texts=['COVID-19']):
            for exclude_text in exclude_texts:
                text = text.replace(exclude_text, '')
            num_tuples = re.findall(r'(\d{3}|\d{2}|\d{1})( \d{3}|\d{2}|\d{1})*', text)
            num_list = [int(x[0] + x[1].replace(' ', '')) for x in num_tuples]
            return num_list

        _gp_covid_stats = {"date": find_date(sentences[0])}

        # First Sentence
        tmp_dict = dict(zip(['cases', 'recoveries', 'deaths'], get_nums(sentences[0])[2:]))
        _gp_covid_stats.update(tmp_dict)

        # Second Sentence
        tmp_dict = dict(zip(['traced', 'de_isolated'], get_nums(sentences[1])[:2]))
        _gp_covid_stats.update(tmp_dict)

        # Third Sentence
        tmp_dict = dict(zip(['hospitalised'], get_nums(sentences[2])))
        _gp_covid_stats.update(tmp_dict)

        return _gp_covid_stats

    gp_covid_stats = get_gp_breakdown_data()

    # DISTRICT BREAKDOWN
    def get_district_data():
        district_table_list = pdfp_obj.pages[0].extract_tables()[0]
        all_list = [[x[i] for x in district_table_list] for i in range(0, len(district_table_list[0]))]
        gp_breakdown_dict = {curr_list[0]: curr_list[1:] for curr_list in all_list}
        gp_breakdown_df = pd.DataFrame.from_dict(gp_breakdown_dict)
        gp_breakdown_df.fillna(0, inplace=True)
        gp_breakdown_df.set_index("DISTRICT", inplace=True)
        gp_breakdown_df.rename(inplace=True, columns={gp_breakdown_df.columns[0]: "CASES",
                                                      gp_breakdown_df.columns[1]: "NEW CASES"})
        for i in range(0, 4):
            gp_breakdown_df.iloc[:, i] = gp_breakdown_df.iloc[:, i].apply(lambda x: x.replace(' ', ''))
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
        table_settings = {"snap_tolerance": 10, "join_tolerance": 15}
        extracted_raw_list = cropped_page.extract_tables(table_settings)[0]
        return extracted_raw_list

    def get_sub_districts_data(raw_list):
        sub_districts_list = []
        curr_sub_district = []
        prev_sub_district = []
        for i in range(1, len(raw_list)):
            curr_list = raw_list[i]
            if curr_sub_district == [] or not (curr_list[0] == None or curr_list[0] == ''):
                #             print(prev_sub_district)
                if prev_sub_district != []:
                    sub_districts_list.append(curr_sub_district)

                curr_sub_district = curr_list
                prev_sub_district = curr_sub_district
            #             print(curr_sub_district)

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
        extracted_raw_list = cropped_page.extract_tables(table_settings)[0]
        return extracted_raw_list

    def get_all_sub_districts(page_start, page_end):
        all_sub_districts = []
        for i in range(page_start, page_end + 1):
            all_sub_districts.extend(get_sub_districts_data(get_table_list(i)))

        def remove_spaces(str_no):
            return str_no.replace(" ", "")

        all_sub_districts = [[x[0], remove_spaces(x[1]), remove_spaces(x[2])] for x in all_sub_districts]

        return all_sub_districts

    all_sub_dists = get_all_sub_districts(1, 4)

    pdfp_obj.close()

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

        # Sedibeng
        sed_keys = "Lesedi Emfuleni Midvaal Unallocated".split(" ")
        sed_dict = dict(zip(sed_keys, [[x[1], x[2]] for x in all_sub_dists[23:27]]))

        # West Rand
        wr_keys = "Mogale Rand_West Merafong Unallocated".split(" ")
        wr_dict = dict(zip(wr_keys, [[x[1], x[2]] for x in all_sub_dists[27:31]]))

        # All Districts
        district_map = {
            'Johannesburg': jhb_dict,
            'Tshwane': tsh_dict,
            'Ekurhuleni': eku_dict,
            'Sedibeng': sed_dict,
            'West Rand': wr_dict
        }
        return district_map

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

    out_list = [
        # Date
        date_yyyymmdd, date_formatted,

        # Gauteng Data
        gp_covid_stats['cases'], ' ',
        gp_covid_stats['recoveries'], gp_covid_stats['deaths'], ' ',
        gp_covid_stats['hospitalised'],

        #  DISTRICT TOTALS DATA
        # ----------------------

        # Johannesburg
        gp_district_df.loc['Johannesburg']['CASES'],
        ' ',
        gp_district_df.loc['Johannesburg']['RECOVERIES'],
        gp_district_df.loc['Johannesburg']['DEATHS'],
        ' ',

        # Ekurhuleni
        gp_district_df.loc['Ekurhuleni']['CASES'],
        gp_district_df.loc['Ekurhuleni']['DEATHS'],
        gp_district_df.loc['Ekurhuleni']['RECOVERIES'],

        # Tshwane
        gp_district_df.loc['Tshwane']['CASES'],
        gp_district_df.loc['Tshwane']['DEATHS'],
        gp_district_df.loc['Tshwane']['RECOVERIES'],

        # Sedibeng
        gp_district_df.loc['Sedibeng']['CASES'],
        gp_district_df.loc['Sedibeng']['DEATHS'],
        gp_district_df.loc['Sedibeng']['RECOVERIES'],

        # West Rand
        gp_district_df.loc['West Rand']['CASES'],
        gp_district_df.loc['West Rand']['DEATHS'],
        gp_district_df.loc['West Rand']['RECOVERIES'],

        # GP Unallocated Cases
        gp_district_df.loc['Unallocated']['CASES'],

        '[Check]',
        ' ',

        #  SUB-DISTRICTS DATA
        # --------------------

        # Johannesburg
        district_map['Johannesburg']['A'][0],  # Cases
        district_map['Johannesburg']['A'][1],  # Recoveries

        district_map['Johannesburg']['B'][0],
        district_map['Johannesburg']['B'][1],

        district_map['Johannesburg']['C'][0],
        district_map['Johannesburg']['C'][1],

        district_map['Johannesburg']['D'][0],
        district_map['Johannesburg']['D'][1],

        district_map['Johannesburg']['E'][0],
        district_map['Johannesburg']['E'][1],

        district_map['Johannesburg']['F'][0],
        district_map['Johannesburg']['F'][1],

        district_map['Johannesburg']['G'][0],
        district_map['Johannesburg']['G'][1],

        district_map['Johannesburg']['Unallocated'][0],
        district_map['Johannesburg']['Unallocated'][1],

        ' ',
        ' ',

        # Tshwane Cases
        district_map['Tshwane'][1][0],
        district_map['Tshwane'][2][0],
        district_map['Tshwane'][3][0],
        district_map['Tshwane'][4][0],
        district_map['Tshwane'][5][0],
        district_map['Tshwane'][6][0],
        district_map['Tshwane'][7][0],
        district_map['Tshwane']['Unallocated'][0],

        ' ',

        # Ekurhuleni Cases
        district_map['Ekurhuleni']['e1'][0],
        district_map['Ekurhuleni']['e2'][0],
        district_map['Ekurhuleni']['n1'][0],
        district_map['Ekurhuleni']['n2'][0],
        district_map['Ekurhuleni']['s1'][0],
        district_map['Ekurhuleni']['s2'][0],
        district_map['Ekurhuleni']['Unallocated'][0],

        ' ',

        # Sedibeng Cases
        district_map['Sedibeng']['Lesedi'][0],
        district_map['Sedibeng']['Emfuleni'][0],
        district_map['Sedibeng']['Midvaal'][0],
        district_map['Sedibeng']['Unallocated'][0],

        ' ',

        # West Rand Cases
        district_map['West Rand']['Mogale'][0],
        district_map['West Rand']['Rand_West'][0],
        district_map['West Rand']['Merafong'][0],
        district_map['West Rand']['Unallocated'][0],

        ' ',
        '[source]',
        '[Comment]',

        # Tshwane Recoveries
        district_map['Tshwane'][1][1],
        district_map['Tshwane'][2][1],
        district_map['Tshwane'][3][1],
        district_map['Tshwane'][4][1],
        district_map['Tshwane'][5][1],
        district_map['Tshwane'][6][1],
        district_map['Tshwane'][7][1],
        district_map['Tshwane']['Unallocated'][1],

        # Ekurhuleni Recoveries
        district_map['Ekurhuleni']['e1'][0],
        district_map['Ekurhuleni']['e2'][0],
        district_map['Ekurhuleni']['n1'][0],
        district_map['Ekurhuleni']['n2'][0],
        district_map['Ekurhuleni']['s1'][0],
        district_map['Ekurhuleni']['s2'][0],
        district_map['Ekurhuleni']['Unallocated'][0],

        # Sedibeng Recoveries
        district_map['Sedibeng']['Lesedi'][1],
        district_map['Sedibeng']['Emfuleni'][1],
        district_map['Sedibeng']['Midvaal'][1],
        # district_map['Sedibeng']['Unallocated'][1],  # Does not seem to be used

        # West Rand Recoveries
        district_map['West Rand']['Mogale'][1],
        district_map['West Rand']['Rand_West'][1],
        district_map['West Rand']['Merafong'][1],
        # district_map['West Rand']['Unallocated'][1],  # Does not seem to be used

    ]

    def list_to_formatted(in_list, delimiter='|'):
        return delimiter.join(map(str, in_list))

    out_str = list_to_formatted(out_list)
    # return district_map
    return out_str
