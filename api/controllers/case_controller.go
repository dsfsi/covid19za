package controllers

import (
	"encoding/csv"
	"fmt"
	"github.com/dsfsi/covid19za/api/models"
	"github.com/dsfsi/covid19za/api/validators"
	"github.com/labstack/echo"
	"log"
	"net/http"
	"strings"
)

const (
	dataSetBaseUrl     = "https://raw.githubusercontent.com/dsfsi/covid19za/master/data/"
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

	provinceParam := ctx.QueryParam("province")
	province := strings.ToUpper(provinceParam)
	if province != "" && !validators.IsValidProvince(province) {
		return &echo.HTTPError{Code: http.StatusBadRequest, Message: "invalid province"}
	}

	var result models.ConfirmedCases
	for _, line := range confirmedCases[1:] {
		if province != "" && province != line[4] {
			continue
		}

		confirmedCase := mapToConfirmedCase(line)
		result = append(result, confirmedCase)
	}

	return ctx.JSON(http.StatusOK, result)
}

func mapToConfirmedCase(line []string) models.ConfirmedCase {
	return models.ConfirmedCase{
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
