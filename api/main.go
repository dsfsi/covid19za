package main

import (
	"github.com/dsfsi/covid19za/api/controllers"
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
	"log"
	"net/http"
	"os"
	controllers2 "covid19za/api/controllers"
)

func main() {
	api := echo.New()
	api.Use(middleware.Logger())
	api.Use(middleware.Recover())
	api.Use(middleware.CORS())
	api.Use(middleware.GzipWithConfig(middleware.GzipConfig{
		Level: 5,
	}))

	caseController := controllers.NewCaseController()
	hospitalController := controllers.HospitalController()

	api.GET("/", func(ctx echo.Context) error {
		return ctx.String(http.StatusOK, "COVID 19 data API for South Africa")
	})

	api.GET("/hospitals/public", hospitalController.GetAllPublicHospitals)
	api.GET("/cases/confirmed", caseController.GetAllConfirmedCases)
	api.GET("/cases/deaths", caseController.GetAllReportedDeaths)
	api.GET("/cases/timeline/tests", caseController.GetTestingTimeline)
	api.GET("/cases/timeline/provincial/cumulative", caseController.GetCumulativeProvincialTimeline)

	addr, err := determineListenAddress()
	if err != nil {
		log.Fatal(err)
	}

	log.Printf("Listening on %s...\n", addr)
	api.Logger.Fatal(api.Start(addr))
}

func determineListenAddress() (string, error) {
	port := os.Getenv("PORT")
	if port == "" {
		return ":5000" + port, nil
	}
	return ":" + port, nil
}
