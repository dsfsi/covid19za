# District Data

This folder includes all the district Covid-19 case data reported on a provincial level. Currently, the provincial governments do not report this data in a standard way.

This Readme is intended to guide the DSFSI research group for capturing data ensuring all province leads follow a common standard.

If the data structures are broken, it will affect third party stakeholders.

# Data Structure

Each province should strive to have only one csv file to capture both district and subdistrict level data.

In the data file, columns are separated by commas. There are three fields to always include: `date`, `YYYYMMDD` and `source`. An example data table is shown below:

| date            | YYYYMMDD | ... | source           |
| --------------- | -------- | --- | ---------------- |
| e.g. 25-06-2020 | 20200625 | ... | e.g. web address |

The `...` represents the province specific district column list.

All existing columns should be kept and not be renamed. To rename a column rather use the combined district keys, defined in the next section. Any new data columns should be added at the end of the column list but before the `source` column.

All the province specific columns need to be defined in `combined_district_keys.csv`.

# Combined District Keys

The [combined_district_keys.csv](https://github.com/dsfsi/covid19za/blob/master/data/district_data/combined_district_keys.csv) combines all the province district keys in a single file.

The purpose of this single file is:

* Be the **single truth** for every province's district column list
* Easy way to convert coded column names to friendly display names
* Avoid adding multiple key files that do not follow the same standard
* Highlight inconsistencies with the existing column name, to improve future column structures
* The key file is not normalised; that would create multiple files adding to the complexity of the standard.

The combined district keys file has the following columns:

#### Province
e.g `EC` which relates to all the province columns names in `covid19za_provincial_cumulative_timeline...` data files.

#### District_level

| District Level | Description | Example |
| - | - | - |
| 0 | Province level data | Total case for `Gauteng` |
| 1 | District level data | Total case for `Johannesburg` |
| 2 | Subdistrict level data | Total case for `Johannesburg A` |

#### Data_title

The coded column name used in the province data file, e.g. `alfred_nzo`.

#### Data_type

Choose a data type defined in the table below:

| Data Type | Description |
| - | - |
| Case | The column captures case data |
| Recovery | The column captures recovery data |
| Death | The column captures death data |
| Active | The column captures active case data |
| Hospital | The column captures hospitalisation data |

#### Friendly_title

A friendly display name that stakeholder can use to represent the data in tables, plots or maps. e.g. `Alfred Nzo`.

#### Cat

This column contains category codes.

`CAT_B` and `DISTRICT` data is defined in [LM_2018.csv](https://github.com/dsfsi/covid19za/blob/master/data/district_data/LM_2018.csv), by the [Municipal Demaraction Board](http://www.demarcation.org.za).

The demarcation names were used as a starting point for most of the provincial data files and provincial governments report according to these demarcations in some form.

A subdistrict is category B and has a `CAT_B` code. Use the `DISTRICT` code for districts and cities.

By providing the category code, any stakeholder can use the key file to match it to their systems.

#### District

This column contains `DISTRICT` demarcation codes and corresponds to level 1 district `Cat` codes. In this way, subdistricts are linked with their corresponding districts, eg. Polokwane (`LIM354`) is a subdistrict of Capricorn (`DC35`).

#### Order

The order of the column in the province's district column list. Some stakeholders rely on the order of the columns not to change.

#### Data_file

The data file that the column comes from. Some provinces have multiple data files.

#### Notes

Complete this field if more information on the district is required that is not represented in any of the fields in the key file.

# District Data

The leads for every province should take responsibility to apply changes the data structure in the correct way, by following the standard in this Readme.

For new columns:

* Add a new record to the combined key file, at the end of the respective section for that province.
* Remember to include the order number in the combined key file.
* Add the column at the end of the district column list, just before the `source` column.
* Most important, be consistent with the column names for the province.

To rename a column:
* Do not rename existing data column.
* Change the `Friend Name` on the combined key file record.

# Eastern Cape

**Province lead:** [@dmackie](https://github.com/dmackie)

# Free State

**Province lead:** [@vukosi](https://github.com/vukosim)

# Gauteng

**Province lead:** [@shaze](https://github.com/shaze)

The primary source is daily figures released by the Gauteng Department of Health (GDHOH). The contributor to this file (shaze) receives the daily release from the GDOH WhatsApp group. This is usually tweeted by the GDOH and the tweet is given as the source. Sometimes the GDOH tweet is delayed by some hours in which case the source will be updated at a later time. If the release is not tweeted the date of the release is given.


Data file: `provincial_gp_cumulative.csv`

Within a column label, a TAB separates the name of a place (e.g. Tshwane) or pseudo place ("GP Unallocated") and a category (e.g. "Cases", "Recoveries", "Hospitalisations"). Within a name are spaces and should be treated as ordinary characters (e.g. West Rand Merafong City).

# KwaZulu Natal

**Province lead:** None

# Limpopo

**Province lead:** [@JosephSefara](https://github.com/JosephSefara)

### Sources
* [Facebook](https://www.facebook.com/LimpopoDepartmentOfHealthBophelong)

# Mpumalanga

**Province lead:** [@lizelgreyling](https://github.com/lizelgreyling)

# Northern Cape

**Province lead:** [@vukosi](https://github.com/vukosim)

# North West

**Province lead:** [@mphomokoatle](https://github.com/mphomokoatle)

# Western Cape

**Province lead:** [@naturofix](https://github.com/naturofix)

### Sources
* Daily updates by Premier Alan Wilde on [Twitter](https://www.westerncape.gov.za/department-of-health/news).

# Testing data

NICD Epidemiology briefings are taken as a source. Week 17 number of tests are computed from the provincial per capita tests given in the report.

# SA Population

### Sources
* Mid-year 2019 Estimates [Stats SA](https://www.statssa.gov.za/publications/P0302/P03022019.pdf)
