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

var NEWSROOM = "http://www.nicd.ac.za/media/alerts/"

/**
Announcements pages follow the pattern of BASE + /speeches/ + some_link
**/
var BASE = "http://www.nicd.ac.za/"
var HREF_REGEX = "covid-19-update"
var REPO = "https://github.com/dsfsi/covid19za.git"

var UNIQUE_LINKS = map[string]bool{}
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
	"Gauteng":      "GP",
	"WesternCape":  "WC",
	"KwaZuluNatal": "KZN",
	"Limpopo":      "LIM",
	"Mpumalanga":   "MP",
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
var AGE = regexp.MustCompile("[0-9]+")

// this breaks if the date format changes on the gov site
var DATE = regexp.MustCompile("[0-9]+ (January|February|March|April|May|June|July|August|September|October|November|December) 2020")

func main() {
	GetCurrent()
	instances := ParseCsv("./current.csv")
	prevID := instances[len(instances)-1].case_id
	results := Crawl(Request(NEWSROOM))
	fmt.Println("Crawling options (Please note that updates before the 16th of March may be unable to be parsed due to formatting inconsistencies)")
	for i, v := range results {
		fmt.Println(i+1, v.link)
	}
	selection := Prompt("Please select an option to crawl 1 - " + strconv.Itoa(len(results)) + "\n")
	id, _ := strconv.Atoi(prevID)
	selectedId, _ := strconv.Atoi(selection)
	newInstances := Parse(results[selectedId], id)
	for _, i := range newInstances {
		fmt.Println(i.ToCsvRepr())
	}
	http.HandleFunc("/", Index)
	http.HandleFunc("/get-updated-csv", GetUpdatedFile)
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		fmt.Println(err)
	}

}

func (i Instance) ToCsvRepr() string {
	return i.case_id + "," +
		i.date + "," +
		i.YYMMDD + "," +
		i.country + "," +
		i.province + "," +
		i.geo_subdivision + "," +
		i.age + "," +
		i.gender + "," +
		i.transmission_type
}

func ParseInstance(dateString string, context string, province string, id int) Instance {
	bio := BIOGRAPHICAL.FindAllString(context, -1)
	ng := NO_GENDER_FOUND.FindAllString(context, -1)
	date := ParseDate(dateString)
	if len(bio) > 0 {
		age := AGE.FindAllString(bio[0], -1)
		idVal := strconv.Itoa(id)
		return Instance{
			case_id:           idVal,
			date:              RemoveNonAlphaNumberic(removeLBR(date.nativeRepr)),
			YYMMDD:            RemoveNonAlphaNumberic(removeLBR(date.YYYYMMDD)),
			country:           COUNTRY,
			province:          province,
			geo_subdivision:   GEOSUBDIVISION + province,
			age:               age[0],
			gender:            strings.Split(bio[0], " ")[2],
			transmission_type: strings.TrimSpace(strings.Replace(strings.Replace(BIOGRAPHICAL.Split(context, -1)[1], "travelled", "Travelled", -1), "who", "", -1)),
		}
	} else {
		age := AGE.FindAllString(ng[0], -1)
		idVal := strconv.Itoa(id)
		return Instance{
			case_id:           idVal,
			date:              RemoveNonAlphaNumberic(removeLBR(date.nativeRepr)),
			YYMMDD:            RemoveNonAlphaNumberic(removeLBR(date.YYYYMMDD)),
			country:           COUNTRY,
			province:          province,
			geo_subdivision:   GEOSUBDIVISION + province,
			age:               age[0],
			gender:            "not specified",
			transmission_type: strings.TrimSpace(strings.Replace(strings.Replace(NO_GENDER_FOUND.Split(context, -1)[1], "travelled", "Travelled", -1), "who", "", -1)),
		}
	}

}

func ParseDate(date string) Date {
	new := strings.Split(strings.Replace(date, " ,", "", -1), " ")
	native := new[0] + "-" + MONTHS[new[1]] + "-" + new[2]
	yyyymmdd := new[2] + MONTHS[new[1]] + new[0]
	return Date{nativeRepr: native, YYYYMMDD: yyyymmdd}
}

func Prompt(prompt string) string {
	reader := bufio.NewReader(os.Stdin)
	fmt.Print(prompt)
	text, _ := reader.ReadString('\n')
	return text
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

func Parse(r Result, id int) []Instance {
	var instances []Instance
	internalID := id
	fmt.Println("NAVIGATING TO " + r.link)
	doc := Request(r.link)
	fmt.Println("PARSING " + r.link)
	dateString := ""
	doc.Find("li").Each(func(i int, s *goquery.Selection) {
		v, e := s.Attr("itemprop")
		if e && v == "datePublished" {
			dateString = s.Text()
		}
	})
	doc.Find("strong").Each(func(i int, s *goquery.Selection) {
		selections := s.Parent().Next().Find("li")
		if selections != nil {
			selections.Each(func(i int, is *goquery.Selection) {
				cleaned := strings.Replace(RemoveNonAlpha(s.Text()), "Province", "", -1)
				if val, ok := PROVINCES[cleaned]; ok {
					internalID++
					instances = append(instances, ParseInstance(dateString, is.Text(), val, internalID))
				}
			})
		}
	})
	return instances
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
		if strings.Contains(href, HREF_REGEX) {
			values := re.FindAllString(item.Text(), -1)
			if !UNIQUE_LINKS[href] {
				if len(values) > 1 {
					results = append(results, Result{link: href, title: item.Text(), count: values[0]})
				} else {
					results = append(results, Result{link: href, title: item.Text(), count: "UNDEF"})
				}
				UNIQUE_LINKS[href] = true
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
	reg, err := regexp.Compile("[^a-zA-Z0-9-]+")
	if err != nil {
		log.Fatal(err)
	}
	processedString := reg.ReplaceAllString(str, "")
	return processedString
}

func RemoveNonAlpha(str string) string {
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

// persky line carriage...
func removeLBR(text string) string {
	re := regexp.MustCompile(`\x{000D}\x{000A}|[\x{000A}\x{000B}\x{000C}\x{000D}\x{0085}\x{2028}\x{2029}]`)
	return re.ReplaceAllString(text, ``)
}
