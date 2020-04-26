package utils

import (
	"github.com/gocarina/gocsv"
	"encoding/csv"
	"log"
	"net/http"
)

func UnmarshalCSV(url string, out interface{}) error {
	resp, err := http.Get(url)
	if err != nil {
		log.Fatalln("Couldn't open the csv file", err)
	}

	reader := csv.NewReader(resp.Body)
	return gocsv.UnmarshalCSV(reader, out)
}
