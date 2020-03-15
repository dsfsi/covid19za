package main

import (
	"fmt"
	"log"
	"regexp"
	"strings"

	"github.com/PuerkitoBio/goquery"
)

var NEWSROOM = "https://www.gov.za/newsroom"
var BASE = "https://www.gov.za/"
var HREF_REGEX = "coronavirus-covid-19"
var TITLE_REGEX = "Coronavirus COVID-19 cases"

type Result struct {
	link  string
	title string
	count string
}

func main() {
	re := regexp.MustCompile("[0-9]+")
	doc, err := goquery.NewDocument("https://www.gov.za/newsroom")

	if err != nil {
		log.Fatal(err)
	}

	doc.Find("a[href]").Each(func(index int, item *goquery.Selection) {
		href, _ := item.Attr("href")
		if strings.Contains(href, HREF_REGEX) && strings.Contains(item.Text(), TITLE_REGEX) {
			fmt.Printf("link: %s - anchor text: %s\n", href, item.Text())
			values := re.FindAllString(item.Text(), -1)
			if
		}
	})

}
