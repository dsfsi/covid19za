# COVID-19 South Africa Media Release Scraping Tool

A simple CLI tool that allows the user to scrape `http://ww.nicd.ac.za/` for new updates related to COVID-19
The original intent was to scrape `gov.za` directly, however the site seems to be intermittently down.

The tool is written in Golang, and as such, is compiled into a stand-alone executable binary that can be run for a command-line on any UNIX based or Windows operating system.

To build from source, pull down the code and execute `go build` in the root of the `./scraper` directory.

At a later stage
`go.mod`, `go.sum`
files will be added so that the tool can be compiled without having to use `go get...` to build dependencies.


```
shiv@LAPTOP-ENNNEGDS:~/dev/projects/covid19za/scraper$ ./scraper
FETCHING DOCUMENT
CRAWLING
Crawling options (Please note that updates before the 16th of March may be unable to be parsed due to formatting inconsistencies)
1 http://www.nicd.ac.za/covid-19-update-18/
2 http://www.nicd.ac.za/covid-19-update-17/
3 http://www.nicd.ac.za/covid-19-update-16/
4 http://www.nicd.ac.za/covid-19-update-15/
5 http://www.nicd.ac.za/covid-19-update-14/
Please select an option to crawl 1 - 5
1
NAVIGATING TO http://www.nicd.ac.za/covid-19-update-18/
FETCHING DOCUMENT
PARSING http://www.nicd.ac.za/covid-19-update-18/
63,16-03-2020,20200316,South Africa,GP,ZA-GP,33,male,Travelled to Spain
64,16-03-2020,20200316,South Africa,GP,ZA-GP,68,year-old-female,Travelled to Austria
65,16-03-2020,20200316,South Africa,GP,ZA-GP,30,male,Travelled to India
66,16-03-2020,20200316,South Africa,GP,ZA-GP,39,male,Travelled to the United States of America
67,16-03-2020,20200316,South Africa,GP,ZA-GP,43,female,Travelled to the United States of America
68,16-03-2020,20200316,South Africa,GP,ZA-GP,50,male,Travelled to France and the United Kingdom
69,16-03-2020,20200316,South Africa,GP,ZA-GP,37,not specified,Travelled to the United States of America, Dubai and Mexico
70,16-03-2020,20200316,South Africa,WC,ZA-WC,39,male,Travelled to Canada
71,16-03-2020,20200316,South Africa,WC,ZA-WC,15,male,Travelled to France
72,16-03-2020,20200316,South Africa,LIM,ZA-LIM,29,male,Travelled to France and the Netherlands
73,16-03-2020,20200316,South Africa,MP,ZA-MP,55,male,Travelled to France
```
// TODO - Remove `static` resources from source tree
// TODO - Reframe `main` function as a CLI control flow path i.e. it is reusable
// TODO - Add a disclaimer related to data format/html inconsistencies in media statements
// TODO - Add a maintenance plan
// TODO - Examples
