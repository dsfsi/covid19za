package models

type ConfirmedCase struct {
	CaseId           string `json:"case_id" csv:"case_id"`
	Date             string `json:"date" csv:"date"`
	Timestamp        string `json:"timestamp" csv:"YYYYMMDD"`
	Country          string `json:"country" csv:"country"`
	Province         string `json:"validators" csv:"province"`
	GeoSubdivision   string `json:"geo_subdivision" csv:"geo_subdivision"`
	Age              string `json:"age" csv:"age"`
	Gender           string `json:"gender" csv:"gender"`
	TransmissionType string `json:"transmission_type" csv:"transmission_type"`
}

type ConfirmedCases []ConfirmedCase
