# Coronavirus COVID-19 (2019-nCoV) Data Repository for South Africa

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3819126.svg)](https://doi.org/10.5281/zenodo.3819126) [![dsJournal](https://img.shields.io/badge/DSJournal-10.5334-B31B1B.svg)](https://doi.org/10.5334/dsj-2020-019)

---

## Archive Notice

**This repository is being prepared for archival.** It represents a comprehensive historical record of COVID-19 data collection, analysis, and modeling efforts for South Africa from March 2020 through end of 2021. The data and code are preserved for:

- Historical research and retrospective analysis
- Academic reference and citation
- Public health preparedness and future pandemic response
- Data science education and methodology demonstration
- Transparency and reproducibility of pandemic-era decision support

The repository remains publicly available under open licenses (MIT for code, CC BY-SA 4.0 for data) to ensure long-term accessibility for researchers, policymakers, and the public.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Historical Context and Impact](#historical-context-and-impact)
- [Repository Structure](#repository-structure)
- [Data Availability](#data-availability)
- [Data Coverage and Completeness](#data-coverage-and-completeness)
- [Technical Documentation](#technical-documentation)
- [Data Sources](#data-sources)
- [Scholarly Work and Citations](#scholarly-work-and-citations)
- [Community Showcase](#community-showcase)
- [Licenses](#licenses)
- [Contributors](#contributors)
- [Contact](#contact)

---

## Project Overview

The **Coronavirus COVID-19 Data Repository for South Africa** was created, maintained, and hosted by the [Data Science for Social Impact (DSFSI) research group](http://www.dsfsi.co.za/) at the University of Pretoria, led by Dr. Vukosi Marivate.

### Mission and Approach

This repository served as the primary open-access COVID-19 data infrastructure for South Africa, providing:

- **Systematically collected data** from official sources (NICD, DoH)
- **Provincial and district-level granularity** for spatial analysis
- **Multiple data streams**: cases, deaths, recoveries, testing, vaccinations, hospital surveillance, excess mortality, and mobility
- **Analysis notebooks** for epidemiological modeling and forecasting
- **Standardized data formats** enabling reproducible research
- **Community collaboration** through open-source contribution

### Key Achievements

- Over **[70+](https://scholar.google.com/scholar?cites=16177923666716456587) scholarly citations** and publications
- **Powered 14+ independent web applications** and dashboards used by the public
- **Daily updates** maintained throughout the pandemic (March 2020 onwards)
- **Collaboration with 40+ volunteers** from academia, industry, and civil society
- **Africa-wide model** inspiring the broader [COVID-19 Africa project](https://github.com/dsfsi/covid19africa)
- **Published in Data Science Journal** (peer-reviewed methodology paper)

**Disclaimer:** We worked to keep data as accurate as possible. Data was collated from NICD and DoH official reports and statements. Updates occurred only after official announcements to ensure data integrity and traceability.

### Related Resources

- **Blog Posts:**
  - [Why we built this and how we are working](http://www.dsfsi.co.za/blog/covid19za-dashboard/)
  - [A call to action across the African continent](http://www.dsfsi.co.za/blog/covida19africa-call-to-action/)
  - [Data Science thoughts on COVID-19 in South Africa](http://www.dsfsi.co.za/blog/a-few-weeks-in-covid19/)

- **Africa-wide Effort:** [COVID-19 Africa Repository](https://github.com/dsfsi/covid19africa)
- **Dashboard:** [COVID-19 Dashboard](http://www.dsfsi.co.za/covid19za-dash/)

---

## Historical Context and Impact

This repository was established in March 2020 at the onset of the COVID-19 pandemic in South Africa. It filled a critical gap by providing:

1. **Open Access to Official Data**: Making government health data accessible in machine-readable formats
2. **Rapid Response Infrastructure**: Enabling real-time analysis by researchers, journalists, and policymakers
3. **Transparent Methodology**: All data collection, cleaning, and analysis methods documented and open-source
4. **Community-Driven Science**: Demonstrating collaborative data science for public good
5. **African Data Leadership**: Setting standards for pandemic data sharing across the continent

The repository supported evidence-based decision-making during the pandemic and continues to serve as a historical record for retrospective analysis and future pandemic preparedness.

---

## Repository Structure

### `/data` - COVID-19 Datasets

Primary directory containing CSV files for South African COVID-19 data:

- **Provincial Timelines**: Cumulative confirmed cases, deaths, recoveries, testing, and vaccinations by province
- **District Data**: Fine-grained geographic data organized by province (Eastern Cape, Free State, Gauteng, KwaZulu-Natal, Limpopo, Mpumalanga, Northern Cape, North West, Western Cape)
- **Hospital Surveillance**: NICD hospital admission and surveillance data
- **Excess Mortality**: SAMRC (South African Medical Research Council) excess deaths data
- **Mobility Data**: Apple, Google, and Facebook mobility indicators
- **Health System Data**: Public and private hospital facility information
- **Official Reports**: Archive of DoH PDF reports and extracted data

See [Data Availability](#data-availability) section for detailed dataset listing.

### `/notebooks` - Analysis and Visualization Notebooks

Jupyter notebooks for epidemiological analysis:

- **Growth Analysis**: Provincial and international COVID-19 growth comparisons
- **Bayesian Inference Models**: Statistical modeling of spreading rates
- **R0 Estimation**: Reproduction number calculations (based on Kevin Systrom's real-time R0 method)
- **Mobility Studies**: Correlation between mobility patterns and case trends
- **Geospatial Visualization**: Choropleth maps and spatial analysis
- **Vaccination Analytics**: Vaccine rollout tracking and analysis

**Usage**: Clone the repository and run notebooks locally. Some notebooks fetch external data; others use local `/data` files.

### `/modelhub` - COVID-19 Forecasting Models

Standardized repository for COVID-19 forecasting and projection models, inspired by the [Reich Lab COVID-19 Forecast Hub](https://covid19forecasthub.org/).

- **Model Directory**: `/modelhub/notebooks/`
- **Template**: `model_template.ipynb` for standardized model development
- **Automation**: Models designed for nightly automated execution
- **Licensing**: Model code (MIT), Model outputs (CC BY-SA 4.0)

### `/scripts` - Data Processing Automation

Python scripts for data collection and processing:

- `realtime_r0.py` - Automated R0 (effective reproduction number) calculation
- `gp_pdf_extractor.py` - Extracts COVID-19 data from Gauteng Province PDF reports (requires `pdfplumber`)
- `mobility_scraper.py` - Scrapes mobility data from various sources
- `sacoronavirus_provincial_vaccine.py` - Vaccination data scraper

**Dependencies**: See individual script headers and `/notebooks/covid-model/requirements.txt`

### `/scraper` - Media Release Scraper (DEPRECATED)

Go-based CLI tool for scraping NICD/DoH media releases. **Note**: No longer functional as NICD/DoH stopped providing individual patient data in releases after March 24, 2020.

Build from source: `go build` in `./scraper` directory

### `/visualisation` - Generated Visualizations

Directory for storing output graphics, charts, and visualizations generated from analysis notebooks.

### `/api` - API Components

API-related code and infrastructure for programmatic data access.

### `/documents` - Documentation and Resources

Additional documentation, methodological notes, and resources.

---

## Data Availability

All datasets are located in the [`/data`](/data) directory and are available in CSV format for ease of analysis.

### Important Data Caveats

**Testing and Reporting Lag**: Daily reports reflect new positive test results released by the National Department of Health or NICD, but significant lag exists between test date and reporting date.

**Example**: In epidemiological Week 1 of 2021 (3-9 Jan), approximately 33,000 new cases were reported in daily announcements. However, the NICD Testing Summary Report for Week 3 of 2021 showed 43,635 positive tests for Week 1. This discrepancy arises because:
- Cases reported in daily announcements may be from prior weeks
- Tests conducted in a given week may only be reported in subsequent weeks

**Implication**: Temporal analyses must account for reporting lag. The reported date does not necessarily reflect the actual test date or illness onset date.

### Active Datasets

Complete, maintained datasets covering the pandemic period:

| Dataset | Description | Repository Link | Raw CSV URL |
|---------|-------------|-----------------|-------------|
| **Provincial Confirmed Cases** | Cumulative confirmed COVID-19 cases by province over time | [Link](/data/covid19za_provincial_cumulative_timeline_confirmed.csv) | [CSV](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_provincial_cumulative_timeline_confirmed.csv) |
| **Provincial Recoveries** | Cumulative recoveries by province over time | [Link](/data/covid19za_provincial_cumulative_timeline_recoveries.csv) | [CSV](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_provincial_cumulative_timeline_recoveries.csv) |
| **Provincial Testing** | Cumulative COVID-19 tests conducted by province | [Link](/data/covid19za_provincial_cumulative_timeline_testing.csv) | [CSV](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_provincial_cumulative_timeline_testing.csv) |
| **Provincial Deaths** | Cumulative deaths by province over time | [Link](/data/covid19za_provincial_cumulative_timeline_deaths.csv) | [CSV](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_provincial_cumulative_timeline_deaths.csv) |
| **Vaccination Timeline** | COVID-19 vaccination rollout data over time | [Link](/data/covid19za_timeline_vaccination.csv) | [CSV](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_timeline_vaccination.csv) |
| **Death Statistics** | Detailed death statistics and demographics | [Link](/data/covid19za_timeline_death_statistics.csv) | [CSV](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_timeline_deaths.csv) |
| **Transmission Type** | Classification of transmission types (local, imported, etc.) | [Link](/data/covid19za_timeline_transmission_type.csv) | [CSV](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_timeline_transmission_type.csv) |
| **Testing Timeline** | National-level testing data over time | [Link](/data/covid19za_timeline_testing.csv) | [CSV](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_timeline_testing.csv) |
| **District Data** | District and subdistrict level data by province | [Link](/data/district_data/) | Multiple CSVs |
| **DoH PDF Reports** | Department of Health PDF reports and extracted data | [Link](/data/doh_pdf) | Multiple files |
| **DoH WhatsApp Archive** | Archive of DoH WhatsApp case update messages | [Link](/data/doh_whatsapp) | Text files |
| **Health Facilities** | Public and private hospital/facility information | [Link](/data/health_system_za_hospitals_v1.csv) | [CSV](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/health_system_za_hospitals_v1.csv) |
| **NICD Daily Reports** | NICD daily national reports | [Link](/data/nicd_daily_national_report.csv) | [CSV](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/nicd_daily_national_report.csv) |
| **NICD Hospital Surveillance** | Hospital admission and surveillance data from NICD | [Link](/data/nicd_hospital_surveillance_data.csv) | [CSV](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/nicd_hospital_surveillance_data.csv) |
| **SAMRC Excess Deaths** | Excess mortality data by province (SAMRC) | [Link](/data/samrc_excess_deaths_province.csv) | [CSV](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/samrc_excess_deaths_province.csv) |
| **Mobility Data** | Apple, Google, and Facebook mobility indicators | [Link](/data/mobility) | Multiple CSVs |
### Deprecated Datasets

**IMPORTANT NOTE:** Since approximately March 24, 2020, individual case-level data was no longer provided by DoH or NICD.

**For provincial-level analysis from March 26, 2020 onwards**, use the `provincial_cumulative_timeline_*` datasets.
**For individual case data up to March 25, 2020**, use the `confirmed_cases` dataset below.

| Dataset | Coverage Period | Repository Link | Raw CSV URL |
|---------|-----------------|-----------------|-------------|
| **Individual Confirmed Cases** | March 5 - March 25, 2020 | [Link](/data/covid19za_timeline_confirmed.csv) | [CSV](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_timeline_confirmed.csv) |
| **Individual Deaths** | Limited early period | [Link](/data/covid19za_timeline_deaths.csv) | [CSV](https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_timeline_deaths.csv) |

---

## Data Coverage and Completeness

### Temporal Coverage

- **Primary Data Collection Period**: March 2020 - End of 2021
- **Individual Case Data**: March 5, 2020 - March 25, 2020 (discontinued by authorities)
- **Provincial Aggregate Data**: March 2020 - End of 2021
- **Vaccination Data**: Begins with vaccine rollout in 2021
- **Hospital Surveillance**: Varies by dataset
- **Excess Mortality**: Provided by SAMRC on periodic basis through 2021

### Geographic Coverage

- **National Level**: All-South Africa aggregates
- **Provincial Level**: All 9 provinces (Eastern Cape, Free State, Gauteng, KwaZulu-Natal, Limpopo, Mpumalanga, Northern Cape, North West, Western Cape)
- **District Level**: District and subdistrict data where available (see `/data/district_data/`)

### Data Completeness Notes

1. **Reporting Changes**: Data collection methods and reporting formats evolved throughout the pandemic
2. **Missing Periods**: Some datasets may have gaps due to reporting delays or changes in official data release practices
3. **Source Dependency**: All data depends on official government reporting; accuracy reflects source data quality
4. **Backfilling**: Some data points were backfilled or corrected in subsequent official reports

---

## Technical Documentation

### Python Environment and Dependencies

**Primary Analysis Environment**: Python 3.7+

**Core Dependencies** (for COVID modeling notebooks in `/notebooks/covid-model/`):
```bash
pip install -r notebooks/covid-model/requirements.txt
```

**Key Libraries**:
- `pandas` - Data manipulation and analysis
- `numpy` - Numerical computing
- `scipy` - Scientific computing (statistics, interpolation)
- `pymc3` - Bayesian statistical modeling
- `matplotlib`, `seaborn` - Visualization
- `requests` - HTTP requests for data fetching
- `pdfplumber` - PDF data extraction (for GP PDF extractor script)

### R Environment

Some notebooks use R for statistical analysis. Required packages vary by notebook.

### Data Format Standards

#### CSV Structure
- **Encoding**: UTF-8
- **Delimiter**: Comma (`,`)
- **Date Format**: `DD-MM-YYYY` (primary format, some datasets use `YYYY-MM-DD`)
- **Province Codes**: Standard South African province abbreviations (EC, FS, GP, KZN, LP, MP, NC, NW, WC)

#### District Data Standards

District-level data follows strict standards documented in `/data/district_data/README.md`:

- **Required Columns**: `date`, `YYYYMMDD`, `source`
- **District Levels**:
  - Level 0: Province-level data
  - Level 1: District-level data
  - Level 2: Subdistrict-level data
- **Column Management**: Do NOT rename existing columns; update friendly names in `combined_district_keys.csv`
- **New Columns**: Add at the end before the `source` column

#### Source Attribution

Most datasets require source attribution (typically the last column). Each new data point should reference the official report or statement.

### Using the Data

#### Quick Start

```bash
# Clone the repository
git clone https://github.com/dsfsi/covid19za.git
cd covid19za

# Install Python dependencies
pip install -r notebooks/covid-model/requirements.txt

# Explore data
cd data
ls -la

# Run analysis notebooks
cd ../notebooks
jupyter notebook
```

#### Accessing Raw Data Programmatically

All CSV files can be accessed directly via raw GitHub URLs:

```python
import pandas as pd

# Load provincial confirmed cases
url = "https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_provincial_cumulative_timeline_confirmed.csv"
df = pd.read_csv(url)
```

#### Running Analysis Notebooks

1. Navigate to `/notebooks` directory
2. Open desired notebook in Jupyter
3. Some notebooks fetch external data; others use local `/data` files
4. Ensure dependencies are installed

#### Running Scripts

```bash
# Calculate real-time R0
python scripts/realtime_r0.py

# Extract data from Gauteng Province PDFs
pip install pdfplumber
python scripts/gp_pdf_extractor.py

# Scrape mobility data
python scripts/mobility_scraper.py
```

## Data Sources

All data in this repository was collected from official government and public health sources to ensure accuracy and credibility.

### Primary Official Sources

| Source | Description | URL |
|--------|-------------|-----|
| **NICD** | National Institute for Communicable Diseases - Primary source for epidemiological data, alerts, and reports | [nicd.ac.za](https://www.nicd.ac.za/media/alerts/) |
| **Department of Health (DoH)** | South African National Department of Health - Official health announcements and statistics | [health.gov.za](http://www.health.gov.za/) |
| **DoH Twitter** | Real-time health updates and announcements | [@HealthZA](https://twitter.com/HealthZA/) |
| **SA Government** | Official government media statements and policy announcements | [gov.za](https://www.gov.za/media-statements) |
| **SAMRC** | South African Medical Research Council - Excess mortality data | [samrc.ac.za](https://www.samrc.ac.za/) |

### Supporting Data Sources

| Source | Description | URL |
|--------|-------------|-----|
| **DHIS Data Dictionary** | National Department of Health Data Dictionary - Standard health data definitions | [dd.dhmis.org](https://dd.dhmis.org/) |
| **Statistics SA** | Statistics South Africa - Demographic and population data | [statssa.gov.za](http://www.statssa.gov.za/) |
| **Apple Mobility** | Apple mobility trend reports | [apple.com/covid19/mobility](https://covid19.apple.com/mobility) |
| **Google Mobility** | Google Community Mobility Reports | [google.com/covid19/mobility](https://www.google.com/covid19/mobility/) |
| **Facebook Data for Good** | Facebook mobility and connectivity data | [dataforgood.facebook.com](https://dataforgood.facebook.com/) |
| **MedPages** | South African medical information resource | [medpages.info](https://www.medpages.info/sf/index.php?page=homepage) |

### Data Collection Methodology

1. **Daily Monitoring**: Official sources were monitored daily for new reports and announcements
2. **Manual Verification**: Data was manually verified against multiple sources when available
3. **Source Attribution**: Each data point includes reference to the source document/announcement
4. **Version Control**: All changes tracked via Git for full transparency and reproducibility
5. **Community Review**: Open-source model allowed community verification and error reporting

---

## Scholarly Work and Citations

### How to Cite This Repository

**For visualizations, notebooks, or web applications:**

> Data Science for Social Impact Research Group @ University of Pretoria, *Coronavirus COVID-19 (2019-nCoV) Data Repository for South Africa.* Available on: https://github.com/dsfsi/covid19za.

**For academic publications - Journal Article:**

```bibtex
@article{marivate2020use,
  Author = {Vukosi Marivate and Herkulaas MvE Combrink},
  Journal = {Data Science Journal},
  Number = {1},
  Pages = {1-7},
  Title = {Use of Available Data To Inform The COVID-19 Outbreak in South Africa: A Case Study},
  Volume = {19},
  Year = {2020},
  DOI = {10.5334/dsj-2020-019},
  URL = {https://doi.org/10.5334/dsj-2020-019}
}
```

**For academic publications - Dataset:**

```bibtex
@dataset{marivate_vukosi_2020_3819126,
  author = {Marivate, Vukosi and Arbi, Riaz and Combrink, Herkulaas and
            de Waal, Alta and Dryza, Henkho and Egersdorfer, Derrick and
            Garnett, Shaun and Gordon, Brent and Greyling, Lizel and
            Lebogo, Ofentswe and Mackie, Dave and Merry, Bruce and
            Mkhondwane, S'busiso and Mokoatle, Mpho and Moodley, Shivan and
            Mtsweni, Jabu and Mtsweni, Nompumelelo and Myburgh, Paul and
            Richter, Jannik and Rikhotso, Vuthlari and Rosen, Simon and
            Sefara, Joseph and van der Walt, Anelda and van Heerden, Schalk and
            Welsh, Jay and Hazelhurst, Scott and Petersen, Chad and
            Mbuvha, Rendani and Dhlamini, Nelisiwe and James, Vaibhavi},
  title = {{Coronavirus disease (COVID-19) case data - South Africa}},
  month = mar,
  year = 2020,
  publisher = {Zenodo},
  doi = {10.5281/zenodo.3819126},
  url = {https://doi.org/10.5281/zenodo.3819126}
}
```

### Research Impact

This repository has been cited in over **70+ scholarly publications** spanning epidemiology, public health, data science, and social sciences.

**Explore citations**: [Google Scholar](https://scholar.google.com/scholar?cites=16177923666716456587&as_sdt=2005&sciodt=0,5&hl=en)

### Publications by Repository Team

- **Marivate, V., & Combrink, H. M. (2020)**. "Use of Available Data To Inform The COVID-19 Outbreak in South Africa: A Case Study." *Data Science Journal*, 19(1), 1-7. [DOI: 10.5334/dsj-2020-019](https://doi.org/10.5334/dsj-2020-019)

---

## Community Showcase

### Web Applications and Dashboards

This repository has powered numerous independent projects that made COVID-19 data accessible to the South African public:

| # | Project | Description | Links | Creator | Country | Status |
|---|---------|-------------|-------|---------|---------|--------|
| 1 | **Covid-19 SA Data** | Data visualizations for the COVID-19 outbreak in South Africa | [Archive](https://web.archive.org/web/2021*/https://covid19data.co.za/) • [GitHub](https://github.com/SimonRosen173/Covid19SAData_JS) | [Simon Rosen](https://github.com/SimonRosen173) | South Africa | Archived |
| 2 | **Covid-19 Testing Map** | Map of COVID-19 testing facilities | [Archive](https://web.archive.org/web/2020*/https://www.ineff.ch/cov19testmap/) • [GitHub](https://github.com/IneffableKoD/cov19testmap) | [Yannick Zehnder](https://github.com/IneffableKoD/) | Switzerland | Archived |
| 3 | **Coronavirus Map** | Interactive coronavirus mapping tool | [Archive](https://web.archive.org/web/2021*/https://coronamap.co.za) • [GitHub](https://github.com/JayWelsh/coronamap) | Jay Welsh | South Africa | Archived |
| 4 | **Covid-19 Telegram Bot** | Corona virus statistics via Telegram | [Bot Link](https://t.me/CoronaZABot) | CodeChap | South Africa | Unknown |
| 5 | **Xitsonga Dashboard** | COVID-19 dashboard in Xitsonga language | [Archive](https://web.archive.org/web/2020*/http://xitsonga.org/covid19) | xitsonga.org | South Africa | Archived |
| 6 | **Hospital Capacity Viz** | Mapping local hospital capacity (public and private) | [Archive](https://web.archive.org/web/2020*/https://elolelo.github.io/covid19/) • [GitHub](https://github.com/elolelo/covid19) | [Nompumelelo](https://github.com/elolelo) | South Africa | Archived |
| 7 | **Covid-19 Trends** | COVID-19 analytics dashboard for South Africa | [Archive](https://web.archive.org/web/2021*/http://www.covid19trends.co.za) • [GitHub](https://github.com/heerden/Covid19TrendsZA) | [Schalk van Heerden](https://github.com/heerden) | South Africa | Archived |
| 8 | **Tshivenda Dashboard** | COVID-19 dashboard in Tshivenda language | [Archive](https://web.archive.org/web/2020*/http://luvenda.com/covid/) | luvenda.com | South Africa | Archived |
| 9 | **Health Facilities Map** | Map of health facilities with comparable details | [Website](http://www.dsfsi.co.za/healthfacilitymap/) • [GitHub](https://github.com/dsfsi/healthfacilitymap) | [Team](http://www.dsfsi.co.za/blog/mapping-healthsystem/) | South Africa | Active |
| 10 | **R Interactive Map** | Health facilities viewer built with R (afrimapr) | [Archive](https://web.archive.org/web/2021*/https://andysouth.shinyapps.io/hosp-viewer-SA-v02/) • [GitHub](https://github.com/afrimapr/afrimapr_dev/tree/master/hospitals-viewer-south-africa/hosp-viewer-SA-v02) | [Dr Andy South](http://andysouth.co.uk/) | United Kingdom | Archived |
| 11 | **R Number Estimation** | Estimating effective reproductive number for SA and provinces (last updated July 2022) | [Website](https://unsupervised.online/static/covid-19/estimating_r_za.html) | [Louis Rossouw](https://github.com/lrossouw) | South Africa | Inactive |
| 12 | **Provincial Modeling** | COVID-19 modeling using reported and excess deaths (last updated July 2021) | [Website](https://unsupervised.online/static/covid-19/modelling_covid-19_in_south_africa_at_a_provincial_level.html) | [Louis Rossouw](https://github.com/lrossouw) | South Africa | Inactive |
| 13 | **Provincial Visualization** | Deaths, cases, recoveries with mobility data visualization | [Archive](https://web.archive.org/web/2021*/http://3.140.191.119:8050/) • [GitHub](https://github.com/ChristopherMarais/Panthera_interview_gcm) | [Christopher Marais](https://github.com/ChristopherMarais/Panthera_interview_gcm) | South Africa | Archived |
| 14 | **Multi-strain Optimization** | Differential Evolution for long-term multi-strain modeling | [IEEE Paper](https://ieeexplore.ieee.org/document/9925558) | CJ Pretorius & MC du Plessis | South Africa | Active |

### Impact Summary

- **14+ web applications** built by independent developers (many now archived as pandemic-era projects)
- **Multi-lingual accessibility** (English, Xitsonga, Tshivenda)
- **International reach** (projects from Switzerland, UK, SA)
- **Diverse applications**: mapping, forecasting, messaging bots, academic research

**Note**: Many community projects have been archived or discontinued as the active pandemic phase ended. Wayback Machine links are provided where original sites are no longer available.

---

## Contributing

**Note**: As this repository transitions to archival status, active contribution may be limited. However, error corrections and data quality improvements are welcome.

### Historical Contribution Workflow

During active maintenance, the contribution process was:

### How to Contribute

1. **Choose or Create an Issue**: Browse existing issues or create a new one describing your contribution
2. **Assign to Yourself**: Take ownership of the issue
3. **Adopt a File**: Add your name to [`covid19za_volunteer_adopted_files.csv`](covid19za_volunteer_adopted_files.csv) listing which files you'll work on
4. **Fork the Repository**: Create your own fork
5. **Make Changes**: Ensure data accuracy and include source attribution
6. **Submit Pull Request**: Follow [GitHub PR guidelines](https://opensource.com/article/19/7/create-pull-request-github)

### Contribution Guidelines

- **Data Accuracy**: Verify all data against official sources
- **Source Attribution**: Include source for every data point
- **Format Consistency**: Follow existing CSV structure and date formats
- **Documentation**: Update relevant documentation for significant changes

### Resources for Contributors

- [Data Science Africa COVID-19 Response](https://www.youtube.com/watch?v=9o0sa7gypMc)
- [IndabaX South Africa: Vukosi Marivate - Using data science to inform the COVID-19 outbreak in Africa](https://www.youtube.com/watch?v=DZOpypSA85I)
- [Stanford CS472 Data science and AI for COVID-19](https://sites.google.com/view/data-science-covid-19)

---

## Contributors

This project was made possible by the dedication of 40+ volunteers from academia, industry, and civil society.

[![Contributors](https://contributors-img.web.app/image?repo=dsfsi/covid19za)](https://github.com/dsfsi/covid19za/graphs/contributors)

Made with [contributors-img](https://contributors-img.web.app).

**Full contributor list**: [GitHub Contributors Graph](https://github.com/dsfsi/covid19za/graphs/contributors)

Special thanks to all volunteers who contributed data collection, validation, analysis, and development throughout the pandemic.

---

## Licenses

**Code**: [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Data**: [![License: CC BY-SA 4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/)

### License Details

- **Code (MIT License)**: All software, scripts, and notebooks are licensed under the MIT License, allowing free use, modification, and distribution with attribution
- **Data (CC BY-SA 4.0)**: All datasets are licensed under Creative Commons Attribution-ShareAlike 4.0, requiring attribution and share-alike for derivative works

These open licenses ensure long-term accessibility and reusability for research, education, and public health purposes.

---

**Project Lead:**
- **Dr. Vukosi Marivate**
  - Email: vukosi.marivate@cs.up.ac.za
  - Twitter: [@vukosi](https://twitter.com/vukosi)
  - Affiliation: Data Science for Social Impact Research Group, University of Pretoria

**Research Group:**
- [Data Science for Social Impact (DSFSI)](http://www.dsfsi.co.za/)
- Department of Computer Science, University of Pretoria

**For Questions:**
- **Data Issues**: Please open a GitHub issue describing the problem
- **Research Collaborations**: Contact Dr. Vukosi Marivate via email
- **General Inquiries**: vukosi.marivate@cs.up.ac.za

---

## Acknowledgments and Support

This project was made possible through support from:

### Funding and Infrastructure Support

- **[International Astronomical Union - Astronomy for Development](http://www.astro4dev.org/)**
- **[Google Cloud Platform](http://cloud.google.com/)**

### Institutional Support

- **University of Pretoria** - Hosting and institutional support
- **Data Science for Social Impact Research Group** - Research leadership and coordination

### Community Support

- **40+ volunteer contributors** - Data collection, validation, and analysis
- **South African data science community** - Code reviews, testing, and feedback
- **14+ independent developers** - Building applications and tools using this data
- **70+ researchers** - Citing and validating this work through scholarly publications

### Special Acknowledgment

We acknowledge the critical work of:
- **NICD (National Institute for Communicable Diseases)** - Primary data collection and public health surveillance
- **National Department of Health** - Official reporting and public health communication
- **SAMRC (South African Medical Research Council)** - Excess mortality analysis
- **All healthcare workers and public health officials** who worked tirelessly during the pandemic

---

## Repository Metadata

- **Repository**: [github.com/dsfsi/covid19za](https://github.com/dsfsi/covid19za)
- **Zenodo DOI**: [10.5281/zenodo.3819126](https://doi.org/10.5281/zenodo.3819126)
- **Data Science Journal DOI**: [10.5334/dsj-2020-019](https://doi.org/10.5334/dsj-2020-019)
- **Primary Language**: Python
- **Data Format**: CSV
- **Status**: Archival
- **Last Active Update**: End of 2021 (varies by dataset)

---

## Additional Resources

### Official Dashboards and Tools
- [DSFSI COVID-19 Dashboard](http://www.dsfsi.co.za/covid19za-dash/)

### Related Projects
- [COVID-19 Africa Repository](https://github.com/dsfsi/covid19africa) - Africa-wide COVID-19 data effort
- [Health Facility Map](http://www.dsfsi.co.za/healthfacilitymap/) - South African health facility mapping

### Educational Resources
- [DSFSI Blog Posts](http://www.dsfsi.co.za/blog/)
- [Data Science for COVID-19 Course Materials](https://sites.google.com/view/data-science-covid-19)

---

**This repository stands as a testament to open science, community collaboration, and the power of data to inform public health responses. We hope it continues to serve researchers, educators, and public health professionals for years to come.**
