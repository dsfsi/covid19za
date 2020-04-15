package controllers

import (
	"github.com/labstack/echo"
	"log"
	"net/http"
	"fmt"
	"github.com/dsfsi/covid19za/api/utils"
	"covid19za/api/mappers"
	"covid19za/api/models"
)

type hospitalController struct {
}

type HospitalController interface {
	GetPublicHospitals(ctx echo.Context) error
	GetPrivateHospitals(ctx echo.Context) error
}

func NewHospitalController() HospitalController {
	return &hospitalController{}
}

func (controller hospitalController) GetPublicHospitals(ctx echo.Context) error {
	log.Println("Endpoint Hit: GetPublicHospitals")

	url := fmt.Sprintf("%s%s", dataSetBaseUrl, publicHospitalPath)
	publicHospitals, err := utils.DownloadCSV(url)
	if err != nil {
		return err
	}

	result := models.PublicHospitals{}
	for _, line := range publicHospitals[1:] {
		hospital := mappers.MapCsvLineToPublicHospitalModel(line)
		result = append(result, hospital)
	}

	return ctx.JSON(http.StatusOK, result)
}

func (controller hospitalController) GetPrivateHospitals(ctx echo.Context) error {
	log.Println("Endpoint Hit: GetPrivateHospitals")

	url := fmt.Sprintf("%s%s", dataSetBaseUrl, privateHospitalPath)
	privateHospitals, err := utils.DownloadCSV(url)
	if err != nil {
		return err
	}

	result := models.PrivateHospitals{}
	for _, line := range privateHospitals[1:] {
		hospital := mappers.MapCsvLineToPrivateHospitalModel(line)
		result = append(result, hospital)
	}

	return ctx.JSON(http.StatusOK, result)
}
