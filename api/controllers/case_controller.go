package controllers

import (
	"encoding/csv"
	"fmt"
	"github.com/dsfsi/covid19za/api/models"
	"github.com/labstack/echo"
	"log"
	"net/http"
)

const(
	dataSetBaseUrl = "https://raw.githubusercontent.com/dsfsi/covid19za/master/data/"
	confirmedCasesPath = "covid19za_timeline_confirmed.csv"
)

type caseController struct {
}

type CaseController interface {
	GetAllConfirmedCases(ctx echo.Context) error
}

func NewCaseController() CaseController {
	return &caseController{}
}

func (controller caseController) GetAllConfirmedCases(ctx echo.Context) error {
	log.Println("Endpoint Hit: returnAllConfirmedCases")
	url := fmt.Sprintf("%s%s", dataSetBaseUrl, confirmedCasesPath)
	confirmedCases, err := downloadCSV(url)
	if err != nil {
		return err
	}

	var result models.ConfirmedCases
	for _, line := range confirmedCases[1:] {
		confirmedCase := models.ConfirmedCase{
			CaseId:           line[0],
			Date:             line[1],
			Timestamp:        line[2],
			Country:          line[3],
			Province:         line[4],
			GeoSubdivision:   line[5],
			Age:              line[6],
			Gender:           line[7],
			TransmissionType: line[8],
		}
		result = append(result, confirmedCase)
	}

	return ctx.JSON(http.StatusOK, result)
}

func downloadCSV(url string) ([][]string, error) {
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
