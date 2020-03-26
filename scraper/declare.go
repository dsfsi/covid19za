package main

import "regexp"

/**
House all static declarations required by the scraper (urls, regex etc)
**/

var NEWSROOM = "http://www.nicd.ac.za/media/alerts/"
var ALTERNATE = "https://sacoronavirus.co.za/category/press-releases-and-notices/"

/**
Announcements pages follow the pattern of BASE + /speeches/ + some_link
**/
var BASE = "http://www.nicd.ac.za/"
var HREF_REGEX = "covid-19-update"
var ALT_HREF = "latest-confirmed-cases-of-covid-19"
var REPO = "https://github.com/dsfsi/covid19za.git"

var GEOSUBDIVISION = "ZA-"
var COUNTRY = "South Africa"

/**
The format of a result from the 'newsroom' page
**/
type Result struct {
	link  string
	title string
	count string
}

/**
Use a map to store the provinces to reduce the need for any sort of lookup
as well as keep the string comparison O(1)
**/
var PROVINCES = map[string]string{
	"GAUTENG":      "GP",
	"WESTERNCAPE":  "WC",
	"KWAZULUNATAL": "KZN",
	"MPUMALANGA":   "MP",
	"LIMPOPO":      "LP",
	"EASTERNCAPE":  "EC",
	"FREESTATE":    "FS",
	"NORTHWEST":    "NW",
	"NORTHERNCAPE": "NC",
}

/**
Map the month to the YY format
**/
var MONTHS = map[string]string{
	"January":   "01",
	"February":  "02",
	"March":     "03",
	"April":     "04",
	"May":       "05",
	"June":      "06",
	"July":      "07",
	"August":    "08",
	"September": "09",
	"October":   "10",
	"November":  "11",
	"December":  "12",
}

/**
	represents a 'Case'
**/
type Instance struct {
	case_id           string
	date              string
	YYMMDD            string
	country           string
	province          string
	geo_subdivision   string
	age               string
	gender            string
	transmission_type string
}

type Date struct {
	nativeRepr string
	YYYYMMDD   string
}

var BIOGRAPHICAL = regexp.MustCompile("A.*male")
var NO_GENDER_FOUND = regexp.MustCompile("A.*-year-old")
var AGE = regexp.MustCompile("[0-9]+|[x]")
var GENDER = regexp.MustCompile("male|female")

// this breaks if the date format changes on the gov site
var DATE = regexp.MustCompile("[0-9]+ (January|February|March|April|May|June|July|August|September|October|November|December) 2020")
