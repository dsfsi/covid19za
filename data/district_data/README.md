

## SA Population

Mid-year 2019 Estimates [Stats SA](https://www.statssa.gov.za/publications/P0302/P03022019.pdf)

## Limpopo Province
**Naming**: See [issue](https://github.com/dsfsi/covid19za/issues/368)
### Sources
- [Facebook](https://www.facebook.com/LimpopoDepartmentOfHealthBophelong)


## Western Cape

### Sources
    Daily updates by the Premier Alan Wilde 
    https://www.westerncape.gov.za/department-of-health/news

## Gauteng

 Primary source are daily figures released by the Gauteng Department of Health.

 The format of data is as follows for people parsing the data

  * `district_gp_keys.csv` The fist column is the names of the labels
      of metros (e.g., Tshwane), districts (e.g. "Johannesburg A") and
      pseudo-districts ("Johannesburg Unallocated"). The second column are the
      areas covered by the districts where known. NB: TABS separate sub-regions/suburbs.
      e.g. "Birchleigh North" is a sub-district of "Ekurhuleni North 1" and there's a tab between Birchleigh and "Birchleigh North". There is a space between "Birchleigh" and "North".

   * `provincial_gp_cumulative.csv` (and the metro files).
       * The column labels are comma separated
       * Within a label a TAB separates the name of a place (e.g. Tshwane) or pseudo place ("GP Unallocated") and a category (e.g. "Cases" ,  "Recoveries", "Hospitalisations"). Within a name are spaces and should be treated as ordinary characters (e.g. West Rand Merafong City)

## Testing data

NICD Epidemiology briefings are taken as source. Week 17 number of tests are computed from the provincial per capita tests given in the report. After that the report gives the data
### Structure

Columns separated by columns. For column labels tabs separate the province name from the data field
   
