package models

type CumulativeProvincialCases struct {
	Date      string    `json:"date" csv:"date"`
	Timestamp string    `json:"timestamp" csv:"YYYYMMDD"`
	Provinces Provinces `json:"provinces"`
	Total     string    `json:"total" csv:"total"`
}

type Provinces struct {
	EasternCape  string `json:"eastern_cape" csv:"EC"`
	FreeState    string `json:"free_state" csv:"FS"`
	Gauteng      string `json:"gauteng" csv:"GP"`
	KwazuluNatal string `json:"kwazulu_natal" csv:"KZN"`
	Limpopo      string `json:"limpopo" csv:"LP"`
	Mpumlanga    string `json:"mpumlanga" csv:"MP"`
	NorthernCape string `json:"northern_cape" csv:"NC"`
	NorthWest    string `json:"north_west" csv:"NW"`
	WesternCape  string `json:"western_cape" csv:"WC"`
	Unknown      string `json:"unknown" csv:"UNKNOWN"`
}

type AllCumulativeProvincialCases []CumulativeProvincialCases
