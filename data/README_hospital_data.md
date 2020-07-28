# Hospital data v1

## 0. Description
The [health_system_za_hospitals_v1.csv](https://github.com/dsfsi/covid19za/tree/master/data/health_system_za_hospitals_v1.csv) is the first version of a bigger collaborative file (contributed by about 4 people) with data ranging from clusters in which hospitals belong to, to the number of beds per hospital amongst other hospital related attributes.

## 1.The start
[This issue](https://github.com/dsfsi/covid19za/issues/115) gives some context and background on how we worked together in collecting, contributing and combining the data. 

## 2. The process
Since there are  various sources in various formats used; I did not programmatically populate the datasets into that one file. Instead, I manually made changes per hospital row using data given about it. [The changes.txt](https://github.com/dsfsi/covid19za/blob/master/changes.txt)  file has a record of what changes have I made from the original file when populating data that is in the file with bed numbers then turned it to this Hospitals v1 file. The main reason for manually populating data is because some of the hospital names have changed over time (different sources have different names) and for the hospitals whose names have not been changed, the naming convention differs from one source file to the other. Eg in [this file](https://github.com/dsfsi/covid19za/blob/Hospital_Data/data/health_system_za_public_hospitals.csv) where I started to work from, most names are shortened while on [this file](https://github.com/anelda/za_open_hospital_data/blob/master/data/tidy_data/hosp_bed_clean.csv) - full names are given. So it’s not easy to immediately identify a correct hospital match from one data source (where it could be shortened) to another different data sources (where it could be written in full name).

## 3. Initial sources used
The table below shows what sources were used and the year when sources were last updated.


| Source                                  | Contributor   |Use of the source    |Last Updated         |
| --------------------------------------- | ------------- |---------------------|---------------------|
| Data from [annual reports](https://github.com/dsfsi/covid19za/tree/Hospital_Data/data) of some public hospitals |Herkulaas| Identification of Hospitals per province,areas of locations etc.|  2019   |
| Data from the [Data library](https://dd.dhmis.org/) ** from DOH     | Nompumelelo|Geo coordinates of public and private hospitals |   2018               |
| Data from various [research outputs](https://figshare.com/articles/dataset/South_African_Hospital_Beds/12073596)      |  Anelda |Hospital Bed numbers, number of surgeons  in  the public and private health sector. And more| From 2016                   |
| Data from [Gauteng's Cluster Policy](https://drive.google.com/file/d/1AhafV1DoTGwNRIx26J12_ICh-3vSVnyt/view)      |   Vukosi  |Public Hospital Number of beds per cluster in Gauteng                   |  2019                   |

** To download health facility data from the data dictionary: Choose Data Dictionary > Data File > NIDS integrated > Groups > All Groups > Download > Org Unit Level > Down to Level 5 and then click submit.

Other sources used to validate minor data uncertainties like classification of a hospital include : this[ Gem file](https://drive.google.com/file/d/140PgnBOdeulGdEWcL6s1jV3JFjx19HZ7/view?usp=sharing) , [Medpages ](https://www.medpages.info/sf/index.php?page=homepage) and Google search engine. For number of beds in some public hospitals, this [National Health Act doc](https://www.gov.za/sites/default/files/gcis_document/201409/35101rg9701gon185a.pdf)  was used. Statistics of South Africa [URL](http://www.statssa.gov.za/) - For Estimates of population per distriction from 2002 -2021. Raw Data here [URL](https://github.com/elolelo/DataProject/blob/master/za_PopEstimates_Districts_StatsSA_WithFinYears_Jan17_coded.csv)

### 3.1 Subsequent sources used

#### On Services offered by public hospitals:
For the services recorded as offered by each public hospital in the public sector - the data used is mainly from [wikipedia](https://en.wikipedia.org/wiki/Main_Page) mostly for the  commonly known  public facilities whose Provincial Health websites does not give details about the services offered. For other public facilities, lesser known or whose details were not on wikipedia, government statements and [briefings](https://www.gov.za/speeches) were used get the relevant information.  Other sources used (not so much) include [this article](https://www.denosa.org.za/Media_View.php?id=36107) and a few pages from [South African Doctors](http://doctors-hospitals-medical-cape-town-south-africa.blaauwberg.net/). 

It should be noted that in Mpumalanga, [this webpage](http://www.mpuhealth.gov.za/Hospitals%20In%20Mpumalanga.html) was used to get the services for each facility. Services are all the same across the public facilites , according to the webapage and besides this webpage, other sources with details could not be found during this step of data collection process. 

For most  hospitals whose services offered details are currently not stated - a note :

> Services for this public hospital could not be found at the time of recording this data.

Is used to highlight that from the sources we are using, at the time that we searched for the services of that specific hospital - we could not find details. This will be updated as we gather more sources to look from.

For some hospitals whose details about services  offered were not clear, a note:

> Services for this public hospital still need to be clerified     

An example of a hospital whose details were not clear is Klerksdorp-Tshepong Hospital,  where from our sources the services are separated between Klerksdorp Hospital and Tshepong Hospital while on some of the previous recordings of this data we have found that this is one hospital. So, more clearity will still be applied.

#### On Services offered by private hospitals/facilites:
Since most private hospitals ( and other private health facilities contained in the [main file](https://github.com/dsfsi/covid19za/blob/master/data/health_system_za_hospitals_v1.csv)) have their own websites , detailing the types of departments available in their facilities and the types of services they offer; instead of re-stating these services on the main file , a note is populated in all the cells for services offered by private hospitals. The note is:
 
> Relevant Private Facility services – visit their website for more details



#### On webpages of hospitals and private health facilities
Most commintly used sources for webpages is [doctors-sa](http://doctors-hospitals-medical-cape-town-south-africa.blaauwberg.net/) , the provincial health websites and for private facilities - the group under which the facilites belong to e.g[ Life Healthcare](https://www.lifehealthcare.co.za/)

 

## 4. Data Limitations
Since this work is work in progress, it is incomplete. There could be inconsistencies with actual names used for hospitals or districts from which the hospitals are located to. These inconsistencies are mainly due to different sources of data from different times and mostly have hospital naming conventions that are not the same across various files used.
The classification of hospitals is also a grey area.Some hospitals could classified as Regional hospital in one source and District in another. So at this point, there is no one complete perfect and reliable way of classifying hospitals.
There are still about 353 hospitals without the bed numbers data. And there is also a small number of hospitals with hospital bed data but no geo coordinates. These limitations are to make the potential users of this data aware of the level of accurancy (or lack thereof) of this data at this point and that it might not be exactly the actual current real information about hospitals.

### To note:

Earlier versions of this file had estimations of population per district as one of the columns for each row of hospital data i.e The district level population data was added as a variable describing the hospital data. Not only was this not a best practise but it was technically not correct and not conducive to reproducible research practices. For population data , visit [this folder](https://github.com/dsfsi/covid19za/tree/master/data/official_stats)

## 5. What's next?
As it is apparent how incomplete this first version of hospital data is; from here we will work with the recent hospital data contributions made by other github users.[This link](https://docs.google.com/spreadsheets/d/1ujiuSd656BfIO3AT86GTr17oveaev-qBuYbu_v45RC4/edit) shows what types of information is still missing.


## 6. Other files worth looking at:
In the hospital branch , there should be a couple of files related to hospitals (including the ones listed below). They contain portions of this main file (and a bit more in some files). They used for various purposes and they contributed to this main v1 of hospital data file.

1.[health_system_za_hospital_id](https://github.com/dsfsi/covid19za/blob/Hospital_Data/data/health_system_za_hospital_library.csv)- This file contains all  hospitals with their assigned ID's.<br>
2.[health_system_za_private_hospitals](https://github.com/dsfsi/covid19za/blob/Hospital_Data/data/health_system_za_private_hospitals.csv) - This file has a list of  private hospitals, not classified into what types of hospitals becuase  access to private hospital data is limited at this point.<br>
3.[health_system_za_public_hospitals](https://github.com/dsfsi/covid19za/blob/Hospital_Data/data/health_system_za_public_hospitals.csv) - This file has a list of different types of public hospitals.<br>
4.[health_system_za_public_hospitals_contacts](https://github.com/dsfsi/covid19za/blob/master/data/health_system_za_public_hospitals_contacts.csv) - This file has contact details of some hospitals.
5.[health_system_za_public_hospitals_extended_details](https://github.com/dsfsi/covid19za/blob/Hospital_Data/data/health_system_za_public_hospitals_extended_details.csv) - This file has a thorough description of hospitals and other details relating to minimum and maximum capacities in hospitals.

6.[health_system_za_district_counts](https://github.com/dsfsi/covid19za/blob/master/data/health_system_za_district_counts.csv) - This file has ( counts) numbers of all different health facilities and services that each district has. The populations per  district estimate  is from [this](https://github.com/dsfsi/covid19za/blob/master/data/staging_area/population-estimates-districts.csv) file - which contains numbers that have been used by the Health System Trust in the their 2018/2019 [District Health Barometer](https://www.hst.org.za/publications/Pages/HSTDistrictHealthBarometer.aspx).

## 7. Other sources useful
The sources below are indirectly used or to be used. For more healthcare data and research purposes, these links below are worth looking at: <br>

1.[Afrimapr work](https://afrimapr.github.io/afrimapr.website/blog/2020/healthsites-app/)<br>
2.[South African Doctors](http://doctors-hospitals-medical-cape-town-south-africa.blaauwberg.net/hospitals_clinics_state_hospitals/state_public_hospitals_clinics_eastern_cape_south_africa/)<br>
3.[South Africa administrative levels](https://data.humdata.org/dataset/south-africa-administrative-levels-0-3-population-statistics)<br>
4.[South African Medical Journal](http://www.samj.org.za/index.php/samj/article/view/12143)<br>
5.[Dell, Angela June's Thesis](https://open.uct.ac.za/handle/11427/22796) and [raw data](https://figshare.com/articles/SURGICAL_RESOURCES_latestmarch2016_xlsx/12066711)<br>
6.[Anelda van der Walt: merging open hospital datasets](http://afrimapr.org/blog/2020/merging-health-facility-lists-part1/)
