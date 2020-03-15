package main

import (
	"bufio"
	"encoding/csv"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"regexp"
	"strconv"
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
var REPO = "https://github.com/dsfsi/covid19za.git"

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
Map the month to the YY format
**/
var MONTHS = map[string]string{
	"jan": "01",
	"feb": "02",
	"mar": "03",
	"apr": "04",
	"may": "05",
	"jun": "06",
	"jul": "07",
	"aug": "08",
	"sep": "09",
	"oct": "10",
	"nov": "11",
	"dec": "12",
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

// this breaks if the date format changes on the gov site
var DATE = regexp.MustCompile("[0-9]*-(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)-2020")

func main() {
	GetCurrent()
	// results := Crawl(Request(NEWSROOM))
	// fmt.Println(results)
	// Parse(results[0])
	// ParseCsv("../data/covid19za_timeline_confirmed.csv")
	// fmt.Println(ParseDate(results[0].link))

	http.HandleFunc("/", Index)
	http.HandleFunc("/get-updated-csv", GetUpdatedFile)
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		fmt.Println(err)
	}

}

func ParseInstance(context string, province string) string {
	bio := BIOGRAPHICAL.FindAllString(context, -1)
	fmt.Println(bio)
	return strings.TrimSpace(strings.Replace(strings.Replace(BIOGRAPHICAL.Split(context, -1)[1], "travelled", "Travelled", -1), "who had", "", -1))
}

func ParseDate(link string) Date {
	n := DATE.FindAllString(link, -1)
	parts := strings.Split(n[0], "-")
	return Date{nativeRepr: n[0], YYYYMMDD: parts[2] + MONTHS[parts[1]] + parts[0]}
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
					ParseInstance(is.Text(), val)
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

func ParseCsv(filename string) []Instance {
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
	return instances
}

func RemoveNonAlphaNumberic(str string) string {
	reg, err := regexp.Compile("[^a-zA-Z]+")
	if err != nil {
		log.Fatal(err)
	}
	processedString := reg.ReplaceAllString(str, "")
	return processedString
}

/**
TODO - When GOV.ZA is back up, this should be done with real data
**/
func AmendCurrent() {
	newEntry := "52,15-03-2020,20200315,South Africa,KZN,ZA-KZN,34,male,Travelled to UK"
	// add a line to current.csv
	f, err := os.OpenFile("current.csv", os.O_APPEND|os.O_WRONLY, 0600)
	if err != nil {
		panic(err)
	}

	defer f.Close()

	if _, err = f.WriteString(newEntry); err != nil {
		panic(err)
	}
}

func GetUpdatedFile(w http.ResponseWriter, r *http.Request) {
	GetCurrent()
	AmendCurrent()
	Openfile, err := os.Open("current.csv")
	defer Openfile.Close() //Close after function return
	if err != nil {
		//File not found, send 404
		http.Error(w, "File not found.", 404)
		return
	}
	FileHeader := make([]byte, 512)
	Openfile.Read(FileHeader)
	FileContentType := http.DetectContentType(FileHeader)

	FileStat, _ := Openfile.Stat()
	FileSize := strconv.FormatInt(FileStat.Size(), 10)

	//Send the headers
	w.Header().Set("Content-Disposition", "attachment; filename=covid19za_timeline_confirmed.csv")
	w.Header().Set("Content-Type", FileContentType)
	w.Header().Set("Content-Length", FileSize)

	//Send the file
	//We read 512 bytes from the file already, so we reset the offset back to 0
	Openfile.Seek(0, 0)
	io.Copy(w, Openfile) //'Copy' the file to the client
	Cleanup()
	return
}

func Index(w http.ResponseWriter, r *http.Request) {
	path := "." + r.URL.Path
	if path == "./" {
		path = "./static/index.html"
	} else {
		path = "./static" + path
	}
	http.ServeFile(w, r, path)
}

/**
FIXME: This should be done with go-git when I have time...
**/
func GetCurrent() {
	//get the response
	resp, err := http.Get("https://raw.githubusercontent.com/dsfsi/covid19za/master/data/covid19za_timeline_confirmed.csv")

	//body
	body, err := ioutil.ReadAll(resp.Body)

	//header
	var header string
	for h, v := range resp.Header {
		for _, v := range v {
			header += fmt.Sprintf("%s %s \n", h, v)
		}
	}

	//append all to one slice
	var write []byte
	write = append(write, body...)

	//write it to a file
	err = ioutil.WriteFile("current.csv", write, 0644)
	if err != nil {
		panic(err)
	}
}

func Cleanup() {
	os.Remove("current.csv")
}
