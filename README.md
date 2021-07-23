# Coronavirus COVID-19 (2019-nCoV) Data Repository for South Africa

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3819126.svg)](https://doi.org/10.5281/zenodo.3819126) [![dsJournal](https://img.shields.io/badge/DSJournal-10.5334-B31B1B.svg)](https://doi.org/10.5334/dsj-2020-019)

Coronavirus COVID-19 (2019-nCoV) Data Repository for South Africa created, maintained and hosted by [Data Science for Social Impact research group](https://dsfsi.github.io/), led by Dr. Vukosi Marivate, at the University of Pretoria.

**Disclaimer:** We have worked to keep the data as accurate as possible. We collate the COVID 19 reporting data from NICD and DoH. We only update that data once there is an official report or statement. For the other data, we work to keep the data as accurate as possible. If you find errors. Make a pull request.

*If you use this repo for any research/development/innovation, please contact us (see contacts below)*

See our blog posts:
* [Why we built this and how we are working](https://dsfsi.github.io/blog/covid19za-dashboard/),
* [How this is a call to action across the African continent](https://dsfsi.github.io/blog/covida19africa-call-to-action/)
* [A few weeks in, Data Science thoughts on COVID-19 in South Africa](https://dsfsi.github.io/blog/a-few-weeks-in-covid19/)

*If you are interested in the **Africa-wide effort**:* Go to [https://github.com/dsfsi/covid19africa](https://github.com/dsfsi/covid19africa)

For information on daily updates on the repo, go to [https://twitter.com/vukosi/status/1239184086633242630?s=20](https://twitter.com/vukosi/status/1239184086633242630?s=20)

## Licenses

Code [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)  | Data [![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)

## Data Available [[/data](/data)]

### Active
| dataset         | url | raw_url[file] |
|-----------------|-----|---------------|
| provincial_cumulative_timeline_confirmed|  [provincial_cumulative_timeline_confirmed](/data/covid19za_provincial_cumulative_timeline_confirmed.csv)   |       [provincial_cumulative_timeline_confirmed.csv](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_provincial_cumulative_timeline_confirmed.csv)         |
| provincial_cumulative_timeline_recoveries|  [provincial_cumulative_timeline_recoveries](/data/covid19za_provincial_cumulative_timeline_recoveries.csv)   |       [provincial_cumulative_timeline_recoveries.csv](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_provincial_cumulative_timeline_recoveries.csv)         |
| provincial_cumulative_timeline_testing|  [provincial_cumulative_timeline_testing](/data/covid19za_provincial_cumulative_timeline_testing.csv)   |       [provincial_cumulative_timeline_testing.csv](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_provincial_cumulative_timeline_testing.csv)         |
| provincial_cumulative_timeline_deaths|  [provincial_cumulative_timeline_deaths](/data/covid19za_provincial_cumulative_timeline_deaths.csv)   |       [provincial_cumulative_timeline_deaths.csv](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_provincial_cumulative_timeline_deaths.csv)         |
| death_statistics |  [covid19za_timeline_death_statistics](/data/covid19za_timeline_death_statistics.csv)   |       [covid19za_timeline_death_statistics.csv](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_timeline_deaths.csv)         |
| transmission_type |  [covid19za_timeline_transmission_type](/data/covid19za_timeline_transmission_type.csv)   |       [covid19za_timeline_transmission_type.csv](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_timeline_transmission_type.csv)         |
| testing |  [covid19za_timeline_testing](/data/covid19za_timeline_testing.csv)   |       [covid19za_timeline_testing.csv](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_timeline_testing.csv)         |
| district_data |  [district_data](/data/district_data/)   |            |
|   DoH PDFs and Extracted CSVs |  [doh_pdf](/data/doh_pdf)   |              |
|   DoH Whatsapp case update archive |  [doh_whatsapp](/data/doh_whatsapp)   |              |
|   health facility data [public and private] |  [health_system_za_hospitals_v1](/data/health_system_za_hospitals_v1.csv)   |         [health_system_za_hospitals_v1.csv](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/health_system_za_hospitals_v1.csv)       |

### Deprecated
**NOTE:** Since around 24 March, we have not gotten individual case data from DoH or NICD. For now if you need provincial counts use the *provincial_cumulative_timeline*. For individual cases up to 25 March, use the *confirmed_cases*.
| dataset         | url | raw_url[file] |
|-----------------|-----|---------------|
| confirmed_cases* [updated to 25 March] |  [covid19za_timeline_confirmed](/data/covid19za_timeline_confirmed.csv)   |       [covid19za_timeline_confirmed.csv](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_timeline_confirmed.csv)         |
| deaths |  [covid19za_timeline_deaths](/data/covid19za_timeline_deaths.csv)   |       [covid19za_timeline_deaths.csv](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_timeline_deaths.csv)         |

\* NICD no longer gives individual case data. Please use **provincial_cumulative_timeline** from 26 March onwards.

## Dashboard
* Google Data Studio Dashboard [URL link](https://dsfsi.github.io/covid19za-dash/)

## Data Sources:
* NICD - South Africa [URL](http://www.nicd.ac.za/media/alerts/)
* Department of Health - South Africa [Main Site](http://www.health.gov.za/), [Twitter](https://twitter.com/HealthZA/)
* South African Government Media Statements [URL](https://www.gov.za/media-statements)
* National Department of Health Data Dictionary [URL](https://dd.dhmis.org/)
* MedPages [URL](https://www.medpages.info/sf/index.php?page=homepage)
* Statistics South Africa [URL](http://www.statssa.gov.za/)

## Contributing
### Options
* *I want to help, but don't have an idea:* You can take a look at the issues to see which one you might be interested in tackling.
* *I have an idea or new feature:* Create a new issue first, assign it to yourself and then fork the repo.

### Adopting a file
Once you have chosen how you are going to contribute, you must list which files you will be working on by adding your name to the adopt-a-file csv file. Edit [covid19za_volunteer_adopted_file](https://github.com/dsfsi/covid19za/blob/master/covid19za_volunteer_adopted_files.csv).

### Submitting Changes [Pull Request]
* See https://opensource.com/article/19/7/create-pull-request-github
### Resources [Get some ideas]
* [Data Science Africa COVID-19 Response](https://www.youtube.com/watch?v=9o0sa7gypMc)
* [IndabaX South Africa: Vukosi Marivate - Using data science to inform the COVID-19 outbreak in Africa](https://www.youtube.com/watch?v=DZOpypSA85I)
* [Stanford \<\> CS472 Data science and AI for COVID-19](https://sites.google.com/view/data-science-covid-19)
## Contributors
[![Contributors](https://contributors-img.web.app/image?repo=dsfsi/covid19za)](https://github.com/dsfsi/covid19za/graphs/contributors)
Made with [contributors-img](https://contributors-img.web.app).
* See https://github.com/dsfsi/covid19za/graphs/contributors

## Contact
* Vukosi Marivate - vukosi.marivate@cs.up.ac.za, [@vukosi](https://twitter.com/vukosi)

## Citing the dataset
**On a visualisation/notebook/webapp:**

> Data Science for Social Impact Research Group @ University of Pretoria, *Coronavirus COVID-19 (2019-nCoV) Data Repository for South Africa.* Available on: https://github.com/dsfsi/covid19za.

**In a publication**

Data Science Journal

>@article{marivate2020use,
	Author = {Vukosi Marivate and Herkulaas MvE Combrink},
	Journal = {Data Science Journal},
	Number = {1},
	Pages = {1-7},
	Title = {Use of Available Data To Inform The COVID-19 Outbreak in South Africa: A Case Study.},
	Volume = {19},
	Year = {2020},
    url = {[https://doi.org/10.5334/dsj-2020-019](https://doi.org/10.5334/dsj-2020-019)}
}

and Dataset

> @dataset{marivate_vukosi_2020_3819126,
  author       = {Marivate, Vukosi and
                  Arbi, Riaz and
                  Combrink, Herkulaas and
                  de Waal, Alta and
                  Dryza, Henkho and
                  Egersdorfer, Derrick and
                  Garnett, Shaun and
                  Gordon, Brent and
                  Greyling,  Lizel and
                  Lebogo, Ofentswe and
                  Mackie, Dave and
                  Merry, Bruce and
                  Mkhondwane, S'busiso and
                  Mokoatle, Mpho and
                  Moodley, Shivan and
                  Mtsweni, Jabu and
                  Mtsweni, Nompumelelo and
                  Myburgh, Paul and
                  Richter, Jannik and
                  Rikhotso, Vuthlari and
                  Rosen, Simon and
                  Sefara, Joseph and
                  van der Walt, Anelda and
                  van Heerden, Schalk and
                  Welsh, Jay and
                  Hazelhurst, Scott and
                  Petersen, Chad and
                  Mbuvha, Rendani and
                  Dhlamini, Nelisiwe and
                  James, Vaibhavi},
  title        = {{Coronavirus disease (COVID-19) case data - South
                   Africa}},
  month        = mar,
  year         = 2020,
  publisher    = {Zenodo},
  doi          = {10.5281/zenodo.3819126},
  url          = {[https://doi.org/10.5281/zenodo.3819126](https://doi.org/10.5281/zenodo.3819126)}
}

## Showcase

Some of COVID-19 Data for South Africa (data in this repo) is currently being used by other independent projects shown in the table below :


| Project Name  | Project Description |  Project Demo    |    Project owner |    Country   |
| ------------- | ------------- |------------|-----------------|------------------|
| 1. Covid-19 SA Data | Data visualizations corresponding to the current Covid-19 outbreak in South Africa |  [[Website](https://simonrosen173.github.io/Covid19SAData/)],[[GitHub Repo](https://github.com/SimonRosen173/Covid19SAData)]| [Simon Rosen](https://github.com/SimonRosen173)| South Africa |
| 2. Covid-19 testing areas| A Covid-19 Testing Facilities Map |[[Website](https://www.ineff.ch/cov19testmap/)],[[GitHub Repo](https://github.com/IneffableKoD/cov19testmap)]| [Yannick Zehnder](https://github.com/IneffableKoD/) | Switzerland |
| 3. Covid-19 Map| A Coronavirus Map | [[Website](https://coronamap.co.za)] [[GitHub Repo](https://github.com/JayWelsh/coronamap)] | Jay Welsh | South Africa |
| 4. Covid-19 Telegram Bot| Corona virus statistics via Telegram | [Link](https://t.me/CoronaZABot) | CodeChap | South Africa |
| 5. Covid-19 Xitsonga Dashboard | Xitsonga Dashboard | [Link](http://xitsonga.org/covid19) | xitsonga.org | South Africa |
| 6. Hospitals' capacity to respond to Covid-19 | Data visualization mapping local hospitals (private ad public) in South Africa | [[Map Viz](https://elolelo.github.io/covid19/)] ,[[Repo](https://github.com/elolelo/covid19)] |[Nompumelelo](https://github.com/elolelo)|South Africa |
| 7. Covid-19 Trends | Covid-19 analytics dashboard for South Africa | [[Website]](http://www.covid19trends.co.za) [[Repo]](https://github.com/heerden/Covid19TrendsZA) | [Schalk van Heerden](https://github.com/heerden) | South Africa | 
| 8. Covid-19 Tshivenda Dashboard | Tshivenda Dashboard | [Link](http://luvenda.com/covid/) | luvenda.com | South Africa |
| 9. Map of Health facilites around me  | Map showing comparable details of hospitals around my location in response to Covid-19  | [[Webpage](https://dsfsi.github.io/healthfacilitymap/)] , [[GitHub Repo](https://github.com/dsfsi/healthfacilitymap)] | [These authors](https://dsfsi.github.io/blog/mapping-healthsystem/)  | South Africa |
|10. R-based Interactive health facilties Map | Afrimapr, mapping health facilities using R-building blocks |[[Webpage](https://andysouth.shinyapps.io/hosp-viewer-SA-v02/)] [[Repo](https://github.com/afrimapr/afrimapr_dev/tree/master/hospitals-viewer-south-africa/hosp-viewer-SA-v02)] | [Dr Andy South](http://andysouth.co.uk/)  |  United Kingdom |


## Support 

We want to acknowledge support from these organisations

* [International Astronomical Union - Astronomy for Development](http://www.astro4dev.org/)
* [Google Cloud Platform](http://cloud.google.com/)
