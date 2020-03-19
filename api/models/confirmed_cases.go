package models

type ConfirmedCase struct {
	CaseId           string `json:"case_id"`
	Date             string `json:"date"`
	Timestamp        string `json:"timestamp"`
	Country          string `json:"country"`
	Province         string `json:"province"`
	GeoSubdivision   string `json:"geo_subdivision"`
	Age              string `json:"age"`
	Gender           string `json:"gender"`
	TransmissionType string `json:"transmission_type"`
}

type ConfirmedCases []ConfirmedCase