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
	conductedTestsPath = "covid19za_timeline_testing.csv"
)

type caseController struct {
}

type CaseController interface {
	GetAllConfirmedCases(ctx echo.Context) error
	GetTestingTimeline(ctx echo.Context) error
}

func NewCaseController() CaseController {
	return &caseController{}
}

//GetAllConfirmedCases returns all confirmed cases
// @Summary Used to get timeline data for confirmed case
// @Description Returns confirmed cases data
// @Success 200 {object} model.ConfirmedCases
// @Accept json
// @Produce json
// @Router /cases/confirmed [GET]
func (controller caseController) GetAllConfirmedCases(ctx echo.Context) error {
	log.Println("Endpoint Hit: GetAllConfirmedCases")
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

//GetTestingTimeline returns testing timeline data
// @Summary Used to get timeline data for conducted tests
// @Description Returns testing timeline data
// @Success 200 {object} model.AllConductedTests
// @Accept json
// @Produce json
// @Router /cases/timeline/tests [GET]
func (controller caseController) GetTestingTimeline(ctx echo.Context) error {
	log.Println("Endpoint Hit: GetTestingTimeline")
	url := fmt.Sprintf("%s%s", dataSetBaseUrl, conductedTestsPath)
	conductedTestsPath, err := utils.DownloadCSV(url)
	if err != nil {
		return err
	}

	var result models.AllConductedTests
	for _, line := range conductedTestsPath[1:] {
		conductedTests := mappers.MapCsvLineToConductedTestsModel(line)
		result = append(result, conductedTests)
	}

	return ctx.JSON(http.StatusOK, result)
}
