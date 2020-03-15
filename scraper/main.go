package main

import (
	"fmt"
	"log"
	"regexp"
	"strings"

	"github.com/PuerkitoBio/goquery"
)

var NEWSROOM = "https://www.gov.za/newsroom"

/**
Announcements pages follow the pattern of BASE + /speeches/ + some_link
**/
var BASE = "https://www.gov.za/"
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
**/
type Instance struct {
}

func main() {
	results := Crawl(Request())
	fmt.Println(results)
}

/**
Hit the /newsroom page and return a parsable document using {@link goquery}
**/
func Request() *goquery.Document {
	doc, err := goquery.NewDocument("https://www.gov.za/newsroom")

	if err != nil {
		log.Fatal(err)
	}

	return doc
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
