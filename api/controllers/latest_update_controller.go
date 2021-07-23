package controllers

import (
	"github.com/labstack/echo"
	"log"
	"net/http"
)

type latestUpdateController struct {
}

type LatestUpdateController interface {
	GetLatestUpdate(ctx echo.Context) error
}

func NewLatestUpdateController() LatestUpdateController {
	return &latestUpdateController{}
}

//GetLatestUpdate returns testing timeline data
// @Summary Used to get a timestamp of the latest update to the data
// @Description Returns a timestamp of the latest update
// @Success 200 {string}
// @Accept json
// @Produce json
// @Router /latest-update [GET]
func (controller latestUpdateController) GetLatestUpdate(ctx echo.Context) error {
	log.Println("Endpoint Hit: GetLatestUpdate")
	result := "2020-04-24T11:45+02" // TODO update with file watcher
	return ctx.JSON(http.StatusOK, result)
}
