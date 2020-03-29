package models

type ReportedDeath struct {
	ReportId       string `json:"report_id"`
	Date           string `json:"date"`
	Timestamp      string `json:"timestamp"`
	Province       string `json:"province"`
	GeoSubdivision string `json:"geo_subdivision"`
	Age            string `json:"age"`
	Gender         string `json:"gender"`
	Notes          string `json:"notes"`
	Source         string `json:"source"`
}

type ReportedDeaths []ReportedDeath
