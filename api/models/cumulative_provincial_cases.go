package models

type CumulativeProvincialCases struct {
	Date      string    `json:"date"`
	Timestamp string    `json:"timestamp"`
	Provinces Provinces `json:"provinces"`
	Total     string    `json:"total"`
}

type Provinces struct {
	EasternCape  string `json:"eastern_cape"`
	FreeState    string `json:"free_state"`
	Gauteng      string `json:"gauteng"`
	KwazuluNatal string `json:"kwazulu_natal"`
	Limpopo      string `json:"limpopo"`
	Mpumlanga    string `json:"mpumlanga"`
	NorthernCape string `json:"northern_cape"`
	NorthWest    string `json:"north_west"`
	WesternCape  string `json:"western_cape"`
	Unknown      string `json:"unknown"`
}

type AllCumulativeProvincialCases []CumulativeProvincialCases
