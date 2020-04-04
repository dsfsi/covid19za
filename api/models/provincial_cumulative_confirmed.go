package models

type CumulativeConfirmedTotal struct {
	Date                   string `json:"date"`
	Timestamp              string `json:"timestamp"`
	NationalConfirmedTotal string `json:"national_confirmed_total"`
}

type CumulativeConfirmedTotals []CumulativeConfirmedTotal
