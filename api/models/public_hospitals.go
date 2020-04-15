package models

type PublicHospital struct {
	Id						string `json:"Id"`
	Name					string `json:"Name"`
	Longitude				string `json:"Long"`
	Latitude				string `json:"Lat"`
	Category				string `json:"Category"`
	Province				string `json:"Province"`
	District				string `json:"district"`
	Subdistrict				string `json:"Subdistrict"`
	DistrictEstPopulation	string `json:"DistrictEstPopulation"`
	ServiceOffered			string `json:"ServiceOffered"`
	Size					string `json:"Size"`
	NumberOfBeds			string `json:"NumberOfBeds"`
	NumberOfPractitioners	string `json:"NumberOfPractitioners"`
	Webpage					string `json:"Webpage"`
}

type PublicHospitals []PublicHospital
