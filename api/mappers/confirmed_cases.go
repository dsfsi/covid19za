package mappers

import "github.com/dsfsi/covid19za/api/models"

func MapCsvLineToConfirmedCaseModel(line []string) models.ConfirmedCase {
	return models.ConfirmedCase{
		CaseId:           line[0],
		Date:             line[1],
		Timestamp:        line[2],
		Country:          line[3],
		Province:         line[4],
		GeoSubdivision:   line[5],
		Age:              line[6],
		Gender:           line[7],
		TransmissionType: line[8],
	}
}
