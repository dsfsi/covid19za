package models

type ConductedTests struct {
	Date            string     `json:"date"`
	Timestamp       string     `json:"timestamp"`
	CumulativeTests string     `json:"cumulative_tests"`
	Recovered       string     `json:"recovered"`
	Hospitalisation string     `json:"hospitalisation"`
	CriticalIcu     string     `json:"critical_icu"`
	Ventilation     string     `json:"ventilation"`
	Deaths          string     `json:"deaths"`
	Contacts        Contacts   `json:"contacts"`
	Travellers      Travellers `json:"travellers"`
}

type Travellers struct {
	Scanned                string `json:"scanned"`
	ElevatedTemperature    string `json:"elevated_temperature"`
	CovidSuspectedCriteria string `json:"covid_suspected_criteria"`
}

type Contacts struct {
	Identified string `json:"contacts_identified"`
	Traced     string `json:"contacts_traced"`
}

type AllConductedTests []ConductedTests
