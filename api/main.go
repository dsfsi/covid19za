package main

import (
	"fmt"
	"github.com/dsfsi/covid19za/api/controllers"
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
	"log"
	"net/http"
	"os"
)

func main()  {
	api := echo.New()
	api.Use(middleware.Logger())
	api.Use(middleware.Recover())

	caseController := controllers.NewCaseController()

	api.GET("/", func(ctx echo.Context) error {
		return ctx.String(http.StatusOK, "COVID 19 data API for South Africa")
	})

	api.GET("/cases/confirmed", caseController.GetAllConfirmedCases)

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
		return "", fmt.Errorf("$PORT not set")
	}
	return ":" + port, nil
}