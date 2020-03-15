package main

import (
	"bufio"
	"encoding/csv"
	"fmt"
	"io"
	"log"
	"os"
	"regexp"
	"strings"

	"github.com/PuerkitoBio/goquery"
)

var NEWSROOM = "https://www.gov.za/newsroom"

/**
Announcements pages follow the pattern of BASE + /speeches/ + some_link
**/
var BASE = "https://www.gov.za"
var HREF_REGEX = "coronavirus-covid-19"
var TITLE_REGEX = "Coronavirus COVID-19"

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
	"Gauteng":      "GP",
	"WesternCape":  "WC",
	"KwaZuluNatal": "KZN",
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

var BIOGRAPHICAL = regexp.MustCompile("A.*male")

func main() {
	results := Crawl(Request(NEWSROOM))
	fmt.Println(results)
	Parse(results[0])
	ParseCsv("../data/covid19za_timeline_confirmed.csv")
	fmt.Println(ParseInstance("A 14 year old female who had travelled to the US and Dubai"))

}

func ParseInstance(c string) string {
	bio := BIOGRAPHICAL.FindAllString(c, -1)
	fmt.Println(bio)
	return strings.TrimSpace(strings.Replace(strings.Replace(BIOGRAPHICAL.Split(c, -1)[1], "travelled", "Travelled", -1), "who had", "", -1))
}

/**
Hit the /newsroom page and return a parsable document using {@link goquery}
**/
func Request(url string) *goquery.Document {
	fmt.Println("FETCHING DOCUMENT")
	doc, err := goquery.NewDocument(url)

	if err != nil {
		log.Fatal(err)
	}

	return doc
}

func Parse(r Result) {
	fmt.Println("NAVIGATING TO " + BASE + r.link)
	doc := Request(BASE + r.link)
	fmt.Println("PARSING " + BASE + r.link)
	doc.Find("strong").Each(func(i int, s *goquery.Selection) {
		selections := s.Parent().Next().Find("li")
		if selections != nil {
			selections.Each(func(i int, is *goquery.Selection) {
				cleaned := RemoveNonAlphaNumberic(s.Text())
				if val, ok := PROVINCES[cleaned]; ok {
					fmt.Println(val + " " + is.Text())
				}
			})
		}
	})
}

/**
Crawl a given document, find <a> tags with 'href' fields, as per https://www.gov.za/newsroom DOM
Pass the found tags through a regular expression check for corona virus 'meta-data'
If the checks are passed, pass through 1 more filter to see if we can determine the number of cases,
if this check fails, the 'cases' is set to UNDEF at this point.
We calculate them later on.
Return a slice of Results
**/
func Crawl(doc *goquery.Document) []Result {
	fmt.Println("CRAWLING")
	var results = make([]Result, 0)

	re := regexp.MustCompile("[0-9]+")

	doc.Find("a[href]").Each(func(index int, item *goquery.Selection) {
		href, _ := item.Attr("href")
		if strings.Contains(href, HREF_REGEX) && strings.Contains(item.Text(), TITLE_REGEX) {
			values := re.FindAllString(item.Text(), -1)
			if len(values) > 1 {
				results = append(results, Result{link: href, title: item.Text(), count: values[0]})
			} else {
				results = append(results, Result{link: href, title: item.Text(), count: "UNDEF"})
			}
		}
	})
	return results
}

func ParseCsv(filename string) {
	csvFile, _ := os.Open(filename)
	reader := csv.NewReader(bufio.NewReader(csvFile))
	var instances []Instance
	for {
		line, error := reader.Read()
		if error == io.EOF {
			break
		} else if error != nil {
			log.Fatal(error)
		}
		instances = append(instances, Instance{
			case_id:           line[0],
			date:              line[1],
			YYMMDD:            line[2],
			country:           line[3],
			province:          line[4],
			geo_subdivision:   line[5],
			age:               line[6],
			gender:            line[7],
			transmission_type: line[8],
		},
		)
	}
	fmt.Println(instances)
}

func RemoveNonAlphaNumberic(str string) string {
	reg, err := regexp.Compile("[^a-zA-Z]+")
	if err != nil {
		log.Fatal(err)
	}
	processedString := reg.ReplaceAllString(str, "")
	return processedString
}
