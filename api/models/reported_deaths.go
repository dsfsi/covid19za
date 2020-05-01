package models

type ReportedDeath struct {
	ReportId       string `json:"report_id" csv:"report_id"`
	Date           string `json:"date" csv:"date"`
	Timestamp      string `json:"timestamp" csv:"YYYYMMDD"`
	Province       string `json:"province" csv:"province"`
	GeoSubdivision string `json:"geo_subdivision" csv:"geo"`
	Age            string `json:"age" csv:"age"`
	Gender         string `json:"gender" csv:"gender"`
	Notes          string `json:"notes" csv:"notes_comorbidity"`
	Source         string `json:"source" csv:"source"`
}

type ReportedDeaths []ReportedDeath
