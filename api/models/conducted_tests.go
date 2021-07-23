package models


type ConductedTests struct {
	Date            string     `json:"date" csv:"date"`
	Timestamp       string     `json:"timestamp" csv:"YYYYMMDD"`
	CumulativeTests string     `json:"cumulative_tests" csv:"cumulative_tests"`
	Recovered       string     `json:"recovered", csv:"recovered"`
	Hospitalisation string     `json:"hospitalisation" csv:"hospitalisation"`
	CriticalIcu     string     `json:"critical_icu" csv:"critical_icu"`
	Ventilation     string     `json:"ventilation" csv:"ventilation"`
	Deaths          string     `json:"deaths" csv:"deaths"`
	Contacts        Contacts   `json:"contacts"`
	Travellers      Travellers `json:"travellers"`
}

type Travellers struct {
	Scanned                string `json:"scanned" csv:"scanned_travellers"`
	ElevatedTemperature    string `json:"elevated_temperature" csv:"passengers_elevated_temperature"`
	CovidSuspectedCriteria string `json:"covid_suspected_criteria" csv:"covid_suspected_criteria"`
}

type Contacts struct {
	Identified string `json:"contacts_identified" csv:"contacts_identified"`
	Traced     string `json:"contacts_traced" csv:"contacts_traced"`
}

type AllConductedTests []ConductedTests
