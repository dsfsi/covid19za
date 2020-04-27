package controllers

import (
	"fmt"
	"github.com/dsfsi/covid19za/api/models"
	"github.com/dsfsi/covid19za/api/utils"
	"github.com/dsfsi/covid19za/api/validators"
	"github.com/labstack/echo"
	"log"
	"net/http"
	"strings"
)

const (
	confirmedCasesPath            = "covid19za_timeline_confirmed.csv"
	conductedTestsPath            = "covid19za_timeline_testing.csv"
	reportedDeathsPath            = "covid19za_timeline_deaths.csv"
	cumulativeProvincialCasesPath = "covid19za_provincial_cumulative_timeline_confirmed.csv"
	publicHospitalPath            = "health_system_za_public_hospitals.csv"
	privateHospitalPath           = "health_system_za_private_hospitals.csv"
)

type caseController struct {
	BaseUrl string
}

type CaseController interface {
	GetAllConfirmedCases(ctx echo.Context) error
	GetAllReportedDeaths(ctx echo.Context) error
	GetTestingTimeline(ctx echo.Context) error
	GetCumulativeProvincialTimeline(ctx echo.Context) error
}

func NewCaseController(baseUrl string) CaseController {
	return &caseController{baseUrl}
}

//GetAllConfirmedCases returns all confirmed cases
// @Summary Used to get individual case data for confirmed cases
// @Description Returns confirmed cases data
// @Success 200 {object} model.ConfirmedCases
// @Accept json
// @Produce json
// @Router /cases/confirmed [GET]
func (controller caseController) GetAllConfirmedCases(ctx echo.Context) error {
	log.Println("Endpoint Hit: GetAllConfirmedCases")
	url := fmt.Sprintf("%s%s", controller.BaseUrl, confirmedCasesPath)
	confirmedCases := models.ConfirmedCases{}
	err := utils.UnmarshalCSV(url, &confirmedCases)
	if err != nil {
		return err
	}

	provinceParam := ctx.QueryParam("province")
	province := strings.ToUpper(provinceParam)
	if province != "" && !validators.IsValidProvince(province) {
		return &echo.HTTPError{Code: http.StatusBadRequest, Message: "invalid province"}
	}

	var result models.ConfirmedCases
	if province == "" {
		result = confirmedCases
	} else {
		result = models.ConfirmedCases{}
		for _, confirmedCase := range confirmedCases {
			if province == confirmedCase.Province {
				result = append(result, confirmedCase)
			}
		}
	}

	return ctx.JSON(http.StatusOK, result)
}

//GetAllReportedDeaths returns all reported deaths
// @Summary Used to get individual case data for reported deaths
// @Description Returns reported death data
// @Success 200 {object} model.ReportedDeath
// @Accept json
// @Produce json
// @Router /cases/deaths [GET]
func (controller caseController) GetAllReportedDeaths(ctx echo.Context) error {
	log.Println("Endpoint Hit: GetAllReportedDeaths")
	url := fmt.Sprintf("%s%s", controller.BaseUrl, reportedDeathsPath)
	reportedDeaths := models.ReportedDeaths{}
	err := utils.UnmarshalCSV(url, &reportedDeaths)
	if err != nil {
		return err
	}

	provinceParam := ctx.QueryParam("province")
	province := strings.ToUpper(provinceParam)
	if province != "" && !validators.IsValidProvince(province) {
		return &echo.HTTPError{Code: http.StatusBadRequest, Message: "invalid province"}
	}

	var result models.ReportedDeaths
	if province == "" {
		result = reportedDeaths
	} else {
		result = models.ReportedDeaths{}
		for _, reportedDeath := range reportedDeaths {
			if province == reportedDeath.Province {
				result = append(result, reportedDeath)
			}
		}
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
	url := fmt.Sprintf("%s%s", controller.BaseUrl, conductedTestsPath)
	result := models.AllConductedTests{}
	err := utils.UnmarshalCSV(url, &result)
	if err != nil {
		return err
	}

	return ctx.JSON(http.StatusOK, result)
}

//GetCumulativeProvincialTimeline returns cumulative provincial timeline data
// @Summary Used to get cumulative provincial timeline data
// @Description Returns cumulative provincial timeline data
// @Success 200 {object} model.AllCumulativeProvincialCases
// @Accept json
// @Produce json
// @Router /cases/timeline/provincial/cumulative [GET]
func (controller caseController) GetCumulativeProvincialTimeline(ctx echo.Context) error {
	log.Println("Endpoint Hit: GetCumulativeProvincialTimeline")
	url := fmt.Sprintf("%s%s", controller.BaseUrl, cumulativeProvincialCasesPath)
	result := models.AllCumulativeProvincialCases{}
	err := utils.UnmarshalCSV(url, &result)
	if err != nil {
		return err
	}

	return ctx.JSON(http.StatusOK, result)
}
