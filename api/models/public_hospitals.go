package models

type PublicHospital struct {
	Id                    string `json:"Id" csv:"ID"`
	Name                  string `json:"Name" csv:"Name"`
	Longitude             string `json:"Long" csv:"Long"`
	Latitude              string `json:"Lat" csv:"Lat"`
	Category              string `json:"Category" csv:"Category"`
	Province              string `json:"Province" csv:"Province"`
	District              string `json:"district" csv:"district"`
	Subdistrict           string `json:"Subdistrict" csv:"subdistrict"`
	DistrictEstPopulation string `json:"DistrictEstPopulation" csv:"district_estimated_population"`
	ServiceOffered        string `json:"ServiceOffered" csv:"service_offered_by_hospital"`
	Size                  string `json:"Size" csv:"size_hospital"`
	NumberOfBeds          string `json:"NumberOfBeds" csv:"number_of_beds"`
	NumberOfPractitioners string `json:"NumberOfPractitioners" csv:"number_of_practitioners"`
	Webpage               string `json:"Webpage" csv:"webpage"`
	GeoSubdivision        string `json:"GeoSubdivision" csv:"geo_subdivision"`
}

type PublicHospitals []PublicHospital
