package utils

import (
	"encoding/csv"
	"log"
	"net/http"
)

func DownloadCSV(url string) ([][]string, error) {
	resp, err := http.Get(url)
	if err != nil {
		log.Fatalln("Couldn't open the csv file", err)
	}

	reader := csv.NewReader(resp.Body)
	records, err := reader.ReadAll()
	if err != nil {
		log.Fatalln("An error encountered ::", err)
		return nil, err
	}

	return records, nil
}
