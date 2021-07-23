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
	BaseUrl string
}

type HospitalController interface {
	GetPublicHospitals(ctx echo.Context) error
	GetPrivateHospitals(ctx echo.Context) error
}

func NewHospitalController(baseUrl string) HospitalController {
	return &hospitalController{baseUrl}
}

func (controller hospitalController) GetPublicHospitals(ctx echo.Context) error {
	log.Println("Endpoint Hit: GetPublicHospitals")

	url := fmt.Sprintf("%s%s", controller.BaseUrl, publicHospitalPath)
	result := models.PublicHospitals{}
	err := utils.UnmarshalCSV(url, &result)
	if err != nil {
		return err
	}

	return ctx.JSON(http.StatusOK, result)
}

func (controller hospitalController) GetPrivateHospitals(ctx echo.Context) error {
	log.Println("Endpoint Hit: GetPrivateHospitals")

	url := fmt.Sprintf("%s%s", controller.BaseUrl, privateHospitalPath)
	result := models.PrivateHospitals{}
	err := utils.UnmarshalCSV(url, &result)
	if err != nil {
		return err
	}

	return ctx.JSON(http.StatusOK, result)
}
