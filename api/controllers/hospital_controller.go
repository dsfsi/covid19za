package controllers

import (
	"fmt"
	"github.com/dsfsi/covid19za/api/models"
	"github.com/dsfsi/covid19za/api/utils"
	"github.com/labstack/echo"
	"log"
	"net/http"
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
	result := models.PublicHospitals{}
	err := utils.UnmarshalCSV(url, &result)
	if err != nil {
		return err
	}

	return ctx.JSON(http.StatusOK, result)
}

func (controller hospitalController) GetPrivateHospitals(ctx echo.Context) error {
	log.Println("Endpoint Hit: GetPrivateHospitals")

	url := fmt.Sprintf("%s%s", dataSetBaseUrl, privateHospitalPath)
	result := models.PrivateHospitals{}
	err := utils.UnmarshalCSV(url, &result)
	if err != nil {
		return err
	}

	return ctx.JSON(http.StatusOK, result)
}
