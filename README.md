# Coronavirus COVID-19 (2019-nCoV) Data Repository for South Africa

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3724083.svg)](https://doi.org/10.5281/zenodo.3724083)

COVID 19 Data for South Africa created, maintained and hosted by [Data Science for Social Impact research group](https://dsfsi.github.io/), led by Dr. Vukosi Marivate, at the University of Pretoria. 

**Disclaimer:** We have worked to keep the data as accurate as possible. We collate the COVID 19 reporting data from NICD and DoH. We only update that data once there is an official report or statement. For the other data, we work to keep the data as accurate as possible. If you find errors. Make a pull request.

*If you use this repo for any research/development/innovation, please contact us (see contacts below)*

See our blog posts: 
* [Why we built this and how we are working](https://dsfsi.github.io/blog/covid19za-dashboard/),
* [How this is a call to action across the African continent](https://dsfsi.github.io/blog/covida19africa-call-to-action/)

*If you are interested in the **Africa-wide effort**:* Go to https://github.com/dsfsi/covid19africa
## Licenses

Code [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)  | Data [![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)

## Data Available [[/data](/data)]

**NOTE:** Since around 24 March, we have not gotten individual case data from DoH or NICD. For now if you need provincial counts use the *provincial_cumulative_timeline*. For indivividual cases up to 25 March, use the *confirmed_cases*.

| dataset         | url | raw_url[file] |
|-----------------|-----|---------------|
| provincial_cumulative_timeline|  [provincial_cumulative_timeline](/data/covid19za_provincial_cumulative_timeline_confirmed.csv)   |       [provincial_cumulative_timeline.csv](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_provincial_cumulative_timeline_confirmed.csv)         |
| confirmed_cases |  [covid19za_timeline_confirmed](/data/covid19za_timeline_confirmed.csv)   |       [covid19za_timeline_confirmed.csv](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_timeline_confirmed.csv)         |
| transmission_type |  [covid19za_timeline_transmission_type](/data/covid19za_timeline_transmission_type.csv)   |       [covid19za_timeline_transmission_type.csv](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_timeline_transmission_type.csv)         |
| testing |  [covid19za_timeline_testing](/data/covid19za_timeline_testing.csv)   |       [covid19za_timeline_testing.csv](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_timeline_testing.csv)         |
|   DoH PDFs and Extracted CSVs |  [doh_pdf](/data/doh_pdf)   |              |
|   DoH Whatsapp case update archive |  [doh_whatsapp](/data/doh_whatsapp)   |              |
|   public_hospitals [validation in progress] |  [health_system_za_public_hospitals](/data/health_system_za_public_hospitals.csv)   |         [health_system_za_public_hospitals.csv](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/health_system_za_public_hospitals.csv)       |

## Visualisation
* Google Data Studio Dashboard [URL link](https://datastudio.google.com/reporting/1b60bdc7-bec7-44c9-ba29-be0e043d8534)
![Dashboard](/visualisation/dashboard.png)
* Coronavirus Map [[Website](https://coronamap.co.za)] [[GitHub Repo](https://github.com/JayWelsh/coronamap)]
![Dashboard](/visualisation/coronamap.png)
## Data Sources:
* NICD - South Africa [URL](http://www.nicd.ac.za/media/alerts/)
* Department of Health - South Africa [Main Site](http://www.health.gov.za/), [Twitter](https://twitter.com/HealthZA/)
* South African Government Media Statements [URL](https://www.gov.za/media-statements)
* National Department of Health Data Dictionary [URL](https://dd.dhmis.org/)
* MedPages[URL](https://www.medpages.info/sf/index.php?page=homepage)
* Statistics South Africa[URL](http://www.statssa.gov.za/)

## Contributing
### Options
* *I want to help, but dont have an idea:* You can take a look at the issues to see which one you might be interested in tackling.
* *I have an idea or new feature:* Create a new issue first, assign it to yourself and then fork the repo. 
### Submitting Changes [Pull Request]
* See https://opensource.com/article/19/7/create-pull-request-github
## Contributors
* See https://github.com/dsfsi/covid19za/graphs/contributors

## Contact
* Vukosi Marivate - vukosi.marivate@cs.up.ac.za, [@vukosi](https://twitter.com/vukosi)

## Citing the dataset
**On a visualisation/notebook/webapp:**

> Data Science for Social Impact Research Group @ University of Pretoria, *Coronavirus COVID-19 (2019-nCoV) Data Repository for South Africa.* Available on: https://github.com/dsfsi/covid19za.


**In a publication**
> @dataset{marivate_vukosi_2020_3723347,
  author       = {Marivate, Vukosi and
                  de Waal, Alta and
                  Combrink, Herkulaas and
                  Lebogo, Ofentswe and
                  Moodley, Shivan and
                  Mtsweni, Nompumelelo and
                  Rikhotso, Vuthlari},
  title        = {{Coronavirus disease (COVID-19) case data - South 
                   Africa}},
  month        = mar,
  year         = 2020,
  publisher    = {Zenodo},
  doi          = {10.5281/zenodo.3723347},
  url          = {[http://doi.org/10.5281/zenodo.3724083](http://doi.org/10.5281/zenodo.3724083)}
}

### Showcase

* [Covid19 SA Data](https://simonrosen173.github.io/Covid19SAData/)
