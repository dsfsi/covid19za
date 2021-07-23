package main

import (
	"flag"
	"github.com/dsfsi/covid19za/api/controllers"
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
	"log"
	"net/http"
	"os"
)

const (
	dataSetBaseUrl = "https://raw.githubusercontent.com/dsfsi/covid19za/master/data/"
)

func cacheControl(next echo.HandlerFunc) echo.HandlerFunc {
	return func(c echo.Context) error {
		c.Response().Header().Set("Cache-control", "public, max-age=120")
		return next(c)
	}
}

func makeAPI(baseUrl string) *echo.Echo {
	api := echo.New()
	api.Use(middleware.Logger())
	api.Use(middleware.Recover())
	api.Use(middleware.CORS())
	api.Use(middleware.GzipWithConfig(middleware.GzipConfig{
		Level: 5,
	}))
	api.Use(cacheControl)

	latestUpdateController := controllers.NewLatestUpdateController()
	caseController := controllers.NewCaseController(baseUrl)
	hospitalController := controllers.NewHospitalController(baseUrl)

	api.GET("/", func(ctx echo.Context) error {
		return ctx.String(http.StatusOK, "COVID 19 data API for South Africa")
	})

	api.GET("/latest-update", latestUpdateController.GetLatestUpdate)
	api.GET("/hospitals/public", hospitalController.GetPublicHospitals)
	api.GET("/hospitals/private", hospitalController.GetPrivateHospitals)
	api.GET("/cases/confirmed", caseController.GetAllConfirmedCases)
	api.GET("/cases/deaths", caseController.GetAllReportedDeaths)
	api.GET("/cases/timeline/tests", caseController.GetTestingTimeline)
	api.GET("/cases/timeline/provincial/cumulative", caseController.GetCumulativeProvincialTimeline)
	return api
}

func main() {
	baseUrlPtr := flag.String("base-url", dataSetBaseUrl, "Base URL from which to retrieve data")
	bindPtr := flag.String("bind", "", "Address to listen on")
	flag.Parse()

	api := makeAPI(*baseUrlPtr)

	addr := *bindPtr
	if addr == "" {
		var err error
		addr, err = determineListenAddress()
		if err != nil {
			log.Fatal(err)
		}
	}

	log.Printf("Listening on %s...\n", addr)
	api.Logger.Fatal(api.Start(addr))
}

func determineListenAddress() (string, error) {
	port := os.Getenv("PORT")
	if port == "" {
		return ":5000", nil
	}
	return ":" + port, nil
}
