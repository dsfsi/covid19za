package controllers

import (
	"github.com/labstack/echo"
	"log"
	"net/http"
	"fmt"
	"github.com/dsfsi/covid19za/api/utils"
	"github.com/dsfsi/covid19za/api/models"
	"github.com/dsfsi/covid19za/api/mappers"
)

type hospitalController struct {
}

type HospitalController interface {
	GetAllPublicHospitals(ctx echo.Context) error
}

func NewHospitalController() HospitalController {
	return &hospitalController{}
}

func (controller hospitalController) GetAllPublicHospitals(ctx echo.Context) error {
	log.Println("Endpoint Hit: GetAllPublicHospitals")
	url := fmt.Sprintf("%s%s", dataSetBaseUrl, publicHospitalPath)
	publicHospitals, err := utils.DownloadCSV(url)
	if err != nil {
		return err
	}

	result := models.Hospital{}
	for _, line := range publicHospitals[1:] {
		hospital := mappers.MapCsvLineToHospitalModel(line)
		result = append(result, hospital)
	}

	return ctx.JSON(http.StatusOK, result)
}
