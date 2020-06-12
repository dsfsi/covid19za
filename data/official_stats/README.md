## Data Usage License
See [LICENSE](LICENSE.md)
## Official Statistics Data

 Data in this folder is  all from the [Statistics SA](http://www.statssa.gov.za/). National,Provincial and District level datasets along with age, gender and population groups breakdown are all contained in this folder.

## Collection Method

Data from the 2019 Mid-Year population estimates was found from this [publication](http://www.statssa.gov.za/?page_id=1854&PPN=P0302&SCH=7668) . It was then extrated and converted to csv. Currently it is being made machine-readable.

Data from prior 2019 population estimates by district level was obtained from [Health System Trust](https://www.hst.org.za/)

##  Where is this data is used ?

#### 1. The Dashboard

The main [dashboard](https://datastudio.google.com/u/0/reporting/1b60bdc7-bec7-44c9-ba29-be0e043d8534/page/ayBLB) of this repo uses the mid-year population estimates located in this folder to scale positive cases by province.

#### 2. The healthcare system dataset

The healthcare system dataset uses the district population estimates to show the number of health facilities available to each district

### Limitation of the data

**Note:** 

1.It has been noted in several places that some of these files have minor errors (errors from  their source documents) such as a total value that is not equal to the sum of males and females. <br>
2. The district population estimates are way over estimated compared to the current population. We are working on getting the current district population data
