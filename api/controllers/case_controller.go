package controllers

import (
	"fmt"
	"github.com/dsfsi/covid19za/api/mappers"
	"github.com/dsfsi/covid19za/api/models"
	"github.com/dsfsi/covid19za/api/utils"
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
	confirmedCases, err := utils.DownloadCSV(url)
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

		confirmedCase := mappers.MapCsvLineToConfirmedCaseModel(line)
		result = append(result, confirmedCase)
	}

	return ctx.JSON(http.StatusOK, result)
}
