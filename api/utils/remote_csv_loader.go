package utils

import (
	"encoding/csv"
	"fmt"
	"github.com/gocarina/gocsv"
	"log"
	"net/http"
	"net/url"
	"os"
)

func UnmarshalCSV(csvUrl string, out interface{}) error {
	parsedUrl, err := url.Parse(csvUrl)
	if err != nil {
		log.Fatalln("Couldn't parse the URL", err)
	}

	var reader *csv.Reader
	if parsedUrl.Scheme == "http" || parsedUrl.Scheme == "https" {
		resp, err := http.Get(csvUrl)
		if err != nil {
			log.Fatalln("Couldn't open the csv file", err)
		}
		reader = csv.NewReader(resp.Body)
	} else if parsedUrl.Scheme == "file" || parsedUrl.Scheme == "" {
		file, err := os.Open(parsedUrl.Path)
		if err != nil {
			log.Fatalln("Couldn't open the csv file", err)
		}
		defer file.Close()
		reader = csv.NewReader(file)
	} else {
		return fmt.Errorf("Only http, https and file URLs are supported, not %s", csvUrl)
	}
	return gocsv.UnmarshalCSV(reader, out)
}
