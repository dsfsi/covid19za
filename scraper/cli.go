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

func Init(args []string) {
	fmt.Println("[WARNING] Please note that media statements prior to (16-03-2020) may not be parseable due to inconsistent html formatting")
	if len(args) == 0 {
		log.Fatal("[ERROR] Please pass an argument to the tool {nicd, cov}")
	}
	parse(args[0])
}

func invalidArgs() {
	log.Fatal("[ERROR] Invalid argument\noptions:\n\tnicd - " + NEWSROOM + "\n\tcov - " + ALTERNATE)
}

func parse(opt string) {
	fmt.Println("[INFO] Selected " + opt)
	prevID := establishContext()
	if strings.EqualFold(opt, "nicd") {
		results := Crawl(Request(NEWSROOM), "1")
		displayOpts(results)
		selection := read("Please select an option to crawl 1 - " + strconv.Itoa(len(results)) + "\n")
		id, _ := strconv.Atoi(prevID)
		selectedId, _ := strconv.Atoi(selection)
		out(ParseNICD(results[selectedId-1], id))
	} else if strings.EqualFold(opt, "cov") {
		results := Crawl(Request(ALTERNATE), "2")
		displayOpts(results)
		selection := read("Please select an option to crawl 1 - " + strconv.Itoa(len(results)) + "\n")
		id, _ := strconv.Atoi(prevID)
		selectedId, _ := strconv.Atoi(selection)
		out(ParseSACOVID(results[selectedId-1], id))

	} else {
		invalidArgs()
	}

}

func displayOpts(results []Result) {
	fmt.Println("[INFO] OPTIONS (select one)\n--------------------------------------------")
	for i, v := range results {
		fmt.Println(i+1, v.link)
	}
}

func out(inst []Instance) {
	fmt.Println("[INFO] OUTPUT\n----------------------------------")
	for _, i := range inst {
		fmt.Println(i.ToCsvRepr())
	}
}

func read(prompt string) string {
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		line := scanner.Text()
		if line == "exit" {
			os.Exit(0)
		}
		return line
	}
	if err := scanner.Err(); err != nil {
		log.Fatal("fatal error encountered reading std::in")
	}
	return ""
}

func establishContext() string {
	GetCurrent()
	instances := ParseCsv("./current.csv")
	prevID := instances[len(instances)-1].case_id
	return prevID
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
		gen := GENDER.FindAllString(bio[0], -1)
		return Instance{
			case_id:           idVal,
			date:              RemoveNonAlphaNumberic(removeLBR(date.nativeRepr)),
			YYMMDD:            RemoveNonAlphaNumberic(removeLBR(date.YYYYMMDD)),
			country:           COUNTRY,
			province:          province,
			geo_subdivision:   GEOSUBDIVISION + province,
			age:               age[0],
			gender:            gen[0],
			transmission_type: TrimTransmissionType(context, true),
		}
	} else {
		age := AGE.FindAllString(ng[0], -1)
		idVal := strconv.Itoa(id)
		return Instance{
			case_id:         idVal,
			date:            RemoveNonAlphaNumberic(removeLBR(date.nativeRepr)),
			YYMMDD:          RemoveNonAlphaNumberic(removeLBR(date.YYYYMMDD)),
			country:         COUNTRY,
			province:        province,
			geo_subdivision: GEOSUBDIVISION + province,
			age:             age[0],
			gender:          "not specified",
			// being extra safe
			transmission_type: TrimTransmissionType(context, false),
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

func TrimTransmissionType(context string, bio bool) string {
	if bio {
		return strings.Replace(strings.Replace(strings.TrimSpace(strings.Replace(strings.Replace(BIOGRAPHICAL.Split(context, -1)[1], "travelled", "Travelled", -1), "who", "", -1)), ",", "", -1), "had ", "", -1)
	}
	return strings.Replace(strings.Replace(strings.TrimSpace(strings.Replace(strings.Replace(NO_GENDER_FOUND.Split(context, -1)[1], "travelled", "Travelled", -1), "who", "", -1)), ",", "", -1), "had ", "", -1)
}

/**
Hit the /newsroom page and return a parsable document using {@link goquery}
**/
func Request(url string) *goquery.Document {
	doc, err := goquery.NewDocument(url)

	if err != nil {
		log.Fatal(err)
	}

	return doc
}

func ParseNICD(r Result, id int) []Instance {
	var instances []Instance
	internalID := id
	doc := Request(r.link)
	dateString := ""
	doc.Find("li").Each(func(i int, s *goquery.Selection) {
		v, e := s.Attr("itemprop")
		if e && v == "datePublished" {
			dateString = s.Text()
		}
	})
	
	doc.Find("strong").Each(func(i int, s *goquery.Selection) {
		fmt.Println(s.Text())
		selections := s.Parent().Next().Find("li")
		if selections != nil {
			selections.Each(func(i int, is *goquery.Selection) {
				cleaned := strings.Replace(RemoveNonAlpha(s.Text()), "Province", "", -1)
				if val, ok := PROVINCES[strings.ToUpper(cleaned)]; ok {
					internalID++
					instances = append(instances, ParseInstance(dateString, is.Text(), val, internalID))
				}
			})
		}
	})
	return instances
}

func ParseSACOVID(r Result, id int) []Instance {
	var instances []Instance
	doc := Request(r.link)
	internalID := id
	dateString := ""
	doc.Find("span").Each(func(i int, s *goquery.Selection) {
		matches := DATE.FindAllString(s.Text(), -1)
		if len(matches) > 0 {
			dateString = matches[0]
		}
	})
	doc.Find("p").Each(func(i int, s *goquery.Selection) {
		selected := s.Find("strong")
		selected.Each(func(i int, str *goquery.Selection) {
			cleaned := RemoveNonAlpha(str.Text())
			if val, ok := PROVINCES[cleaned]; ok {
				lines := strings.Split(strings.TrimSpace(s.Text()), "\n")
				for i := 1; i < len(lines); i++ {
					// Gotcha; weird hypen/dash usage
					formatted := strings.TrimSpace(strings.Replace(strings.Replace(lines[i], "-", "", -1), "–", "", -1))
					internalID++
					instances = append(instances, ParseInstance(dateString, formatted, val, internalID))
				}
			}
		})
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
func Crawl(doc *goquery.Document, opt string) []Result {
	var results = make([]Result, 0)
	hrefRegex := ""

	if opt == "1" {
		hrefRegex = HREF_REGEX
	} else {
		hrefRegex = ALT_HREF
	}
	re := regexp.MustCompile("[0-9]+")

	doc.Find("a[href]").Each(func(index int, item *goquery.Selection) {
		href, _ := item.Attr("href")
		if strings.Contains(href, hrefRegex) {
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

func RemoveLeadingDash(str string) string {
	reg, err := regexp.Compile("[^a-zA-Z0-9]+")
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
