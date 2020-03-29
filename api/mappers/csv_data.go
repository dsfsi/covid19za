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

func MapCsvLineToReportedDeathModel(line []string) models.ReportedDeath {
	return models.ReportedDeath{
		ReportId:       line[0],
		Date:           line[1],
		Timestamp:      line[2],
		Province:       line[3],
		GeoSubdivision: line[4],
		Age:            line[5],
		Gender:         line[6],
		Notes:          line[7],
		Source:         line[8],
	}
}

func MapCsvLineToConductedTestsModel(line []string) models.ConductedTests {
	return models.ConductedTests{
		Date:            line[0],
		Timestamp:       line[1],
		CumulativeTests: line[2],
		Recovered:       line[3],
		Hospitalisation: line[4],
		CriticalIcu:     line[5],
		Ventilation:     line[6],
		Deaths:          line[7],
		Contacts: models.Contacts{
			Identified: line[8],
			Traced:     line[9],
		},
		Travellers: models.Travellers{
			Scanned:                line[10],
			ElevatedTemperature:    line[11],
			CovidSuspectedCriteria: line[12],
		},
	}
}
