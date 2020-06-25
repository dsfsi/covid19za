# COVID-19 South Africa Media Release Scraping Tool

A simple CLI tool that allows the user to scrape `http://www.nicd.ac.za/` for new updates related to COVID-19
The original intent was to scrape `gov.za` directly, however the site seems to be intermittently down.

The tool is written in Golang, and as such, is compiled into a stand-alone executable binary that can be run for a command-line on any UNIX based or Windows operating system.

To build from source, pull down the code and execute `go build` in the root of the `./scraper` directory.

## Usage

To user the scraper, simply run `./scraper` with one of the following arguments:
1. `./scraper nicd` - this configuration will retrieve updates from `http://www.nicd.ac.za`
2. `./scraped cov`  - this configuration will retrieve updates from `https://sacoronavirus.co.za`

## Examples

### NICD

```
shiv@LAPTOP-ENNNEGDS:~/dev/projects/covid19za/scraper$ ./scraper nicd
[WARNING] Please note that media statements prior to (16-03-2020) may not be parseable due to inconsistent html formatting
[INFO] Selected http://www.nicd.ac.za/media/alerts/
[INFO] OPTIONS (select one)
--------------------------------------------
1 http://www.nicd.ac.za/covid-19-update-21/
2 http://www.nicd.ac.za/covid-19-update-20/
3 http://www.nicd.ac.za/covid-19-update-19/
4 http://www.nicd.ac.za/covid-19-update-18/
5 http://www.nicd.ac.za/covid-19-update-17/
6 http://www.nicd.ac.za/covid-19-update-16/
7 http://www.nicd.ac.za/covid-19-update-15/
8 http://www.nicd.ac.za/covid-19-update-14/
1
[INFO] OUTPUT
----------------------------------
151,19-03-2020,20200319,South Africa,GP,ZA-GP,41,female,Travelled to the Democratic Republic of Congo
152,19-03-2020,20200319,South Africa,GP,ZA-GP,43,female,Travelled to the Democratic Republic of Congo
153,19-03-2020,20200319,South Africa,GP,ZA-GP,37,female,with no international travel history
154,19-03-2020,20200319,South Africa,GP,ZA-GP,54,female,Travelled to the United Kingdom
155,19-03-2020,20200319,South Africa,GP,ZA-GP,58,male,Travelled to the United Kingdom
156,19-03-2020,20200319,South Africa,GP,ZA-GP,38,male,Travelled to France
157,19-03-2020,20200319,South Africa,GP,ZA-GP,70,female,Travelled to the United States of America
158,19-03-2020,20200319,South Africa,GP,ZA-GP,30,male,Travelled to Spain
159,19-03-2020,20200319,South Africa,GP,ZA-GP,45,male,Travelled to the Democratic Republic of Congo
160,19-03-2020,20200319,South Africa,GP,ZA-GP,85,male,Travelled to Switzerland
161,19-03-2020,20200319,South Africa,GP,ZA-GP,64,male,Travelled to Vietnam and Thailand
162,19-03-2020,20200319,South Africa,GP,ZA-GP,41,male,Travelled to the Netherlands
163,19-03-2020,20200319,South Africa,GP,ZA-GP,23,male,with pending travel history
164,19-03-2020,20200319,South Africa,GP,ZA-GP,5,female,with pending travel history
165,19-03-2020,20200319,South Africa,GP,ZA-GP,44,male,with pending travel history
166,19-03-2020,20200319,South Africa,KZN,ZA-KZN,71,female,Travelled to the United Kingdom
167,19-03-2020,20200319,South Africa,KZN,ZA-KZN,26,male,Travelled to Mexico and the United States of America
168,19-03-2020,20200319,South Africa,KZN,ZA-KZN,29,female,with pending travel history
169,19-03-2020,20200319,South Africa,LIM,ZA-LIM,56,female,Travelled to France
170,19-03-2020,20200319,South Africa,WC,ZA-WC,53,female,Travelled to the United Kingdom
171,19-03-2020,20200319,South Africa,WC,ZA-WC,30,female,Travelled to the Netherlands and Qatar
172,19-03-2020,20200319,South Africa,WC,ZA-WC,45,male,Travelled to Mexico
173,19-03-2020,20200319,South Africa,WC,ZA-WC,70,female,Travelled to the United States of America
174,19-03-2020,20200319,South Africa,WC,ZA-WC,25,female,Travelled to the United Kingdom
175,19-03-2020,20200319,South Africa,WC,ZA-WC,37,female,Travelled to the United Kingdom
176,19-03-2020,20200319,South Africa,WC,ZA-WC,43,female,Travelled to the United States of America
177,19-03-2020,20200319,South Africa,WC,ZA-WC,31,male,Travelled to Spain and the Netherlands
178,19-03-2020,20200319,South Africa,WC,ZA-WC,53,female,Travelled to Switzerland Austria Czech Republic and Germany
179,19-03-2020,20200319,South Africa,WC,ZA-WC,22,female,Travelled to the United Kingdom
180,19-03-2020,20200319,South Africa,WC,ZA-WC,63,male,Travelled to Switzerland Czech Republic and Germany
181,19-03-2020,20200319,South Africa,WC,ZA-WC,22,male,Travelled to Spain and the Netherlands
182,19-03-2020,20200319,South Africa,WC,ZA-WC,32,male,Travelled to the United States of America
183,19-03-2020,20200319,South Africa,WC,ZA-WC,37,male,with pending travel history
184,19-03-2020,20200319,South Africa,WC,ZA-WC,34,male,with pending travel history
```

### COV

```
shiv@LAPTOP-ENNNEGDS:~/dev/projects/covid19za/scraper$ ./scraper cov
[WARNING] Please note that media statements prior to (16-03-2020) may not be parseable due to inconsistent html formatting
[INFO] Selected http://www.nicd.ac.za/media/alerts/
[INFO] OPTIONS (select one)
--------------------------------------------
1 https://sacoronavirus.co.za/2020/03/19/latest-confirmed-cases-of-covid-19-19th-march-2020/
2 https://sacoronavirus.co.za/2020/03/18/latest-confirmed-cases-of-covid-19-18th-march-2020/
3 https://sacoronavirus.co.za/2020/03/17/latest-confirmed-cases-of-covid-19-17-march-2020/
4 https://sacoronavirus.co.za/2020/03/12/latest-confirmed-cases-of-covid-19-in-south-africa-12th-march/
5 https://sacoronavirus.co.za/2020/03/11/latest-confirmed-cases-of-covid-19-in-south-africa-11th-march/
1
[INFO] OUTPUT
----------------------------------
151,19-03-2020,20200319,South Africa,GP,ZA-GP,41,female,Travelled to DRC
152,19-03-2020,20200319,South Africa,GP,ZA-GP,43,female,Travelled to the UK
153,19-03-2020,20200319,South Africa,GP,ZA-GP,54,female,Travelled to the UK
154,19-03-2020,20200319,South Africa,GP,ZA-GP,58,male,Travelled to the UK
155,19-03-2020,20200319,South Africa,GP,ZA-GP,38,male,Travelled to France
156,19-03-2020,20200319,South Africa,GP,ZA-GP,70,female,Travelled to USA
157,19-03-2020,20200319,South Africa,GP,ZA-GP,30,male,Travelled to Spain
158,19-03-2020,20200319,South Africa,GP,ZA-GP,45,male,Travelled to DRC
159,19-03-2020,20200319,South Africa,GP,ZA-GP,85,male,Travelled to Switzerland
160,19-03-2020,20200319,South Africa,GP,ZA-GP,64,male,Travelled to Vietnam and Thailand
161,19-03-2020,20200319,South Africa,GP,ZA-GP,41,male,Travelled to Netherlands
162,19-03-2020,20200319,South Africa,GP,ZA-GP,37,female,with no international travel history
163,19-03-2020,20200319,South Africa,GP,ZA-GP,23,male,with no contact details on lab form information being obtained from the private doctor
164,19-03-2020,20200319,South Africa,GP,ZA-GP,5,female,with no contact details on lab form information being obtained from the private doctor
165,19-03-2020,20200319,South Africa,GP,ZA-GP,44,male,with no contact details on lab form information being obtained from the private doctor
166,19-03-2020,20200319,South Africa,KZN,ZA-KZN,71,female,Travelled to the UK
167,19-03-2020,20200319,South Africa,KZN,ZA-KZN,26,male,Travelled to Mexico and USA
168,19-03-2020,20200319,South Africa,KZN,ZA-KZN,29,female,with no contact details on lab form information being obtained from private doctor
169,19-03-2020,20200319,South Africa,LIM,ZA-LIM,56,female,Travelled to France
170,19-03-2020,20200319,South Africa,WC,ZA-WC,53,female,Travelled to the UK
171,19-03-2020,20200319,South Africa,WC,ZA-WC,30,male,Travelled to Netherlands and Qatar
172,19-03-2020,20200319,South Africa,WC,ZA-WC,45,male,Travelled to Mexico
173,19-03-2020,20200319,South Africa,WC,ZA-WC,70,female,Travelled to USA
174,19-03-2020,20200319,South Africa,WC,ZA-WC,25,female,Travelled to the UK
175,19-03-2020,20200319,South Africa,WC,ZA-WC,37,female,Travelled to the UK
176,19-03-2020,20200319,South Africa,WC,ZA-WC,43,female,Travelled to USA
177,19-03-2020,20200319,South Africa,WC,ZA-WC,31,male,Travelled to the Spain and Netherlands
178,19-03-2020,20200319,South Africa,WC,ZA-WC,53,female,Travelled to the Switzerland Austria Czech Republic and Germany
179,19-03-2020,20200319,South Africa,WC,ZA-WC,22,female,Travelled to the UK
180,19-03-2020,20200319,South Africa,WC,ZA-WC,63,male,Travelled to the Switzerland Austria Czech Republic and Germany
181,19-03-2020,20200319,South Africa,WC,ZA-WC,22,female,Travelled to Spain and Netherlands
182,19-03-2020,20200319,South Africa,WC,ZA-WC,32,male,Travelled to USA
183,19-03-2020,20200319,South Africa,WC,ZA-WC,37,male,with no contact details on lab form
184,19-03-2020,20200319,South Africa,WC,ZA-WC,53,male,with no international travel history
```

Maintained by @cishiv
