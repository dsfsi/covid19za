package models

type Hospital struct {
	Id						string `json:"Id"`
	Name					string `json:"Name"`
	Longitude				string `json:"Long"`
	Latitude				string `json:"Lat"`
	Category				string `json:"Category"`
	Province				string `json:"Province"`
	District				string `json:"district"`
	Subdistrict				string `json:"subdistrict"`
	DistrictEstPopulation	string `json:"district_estimated_population"`
	ServiceOffered			string `json:"service_offered_by_hospital"`
	Size					string `json:"size_hospital"`
	NumberOfBeds			string `json:"number_of_beds"`
	NumberOfPractitioners	string `json:"number_of_practitioners"`
	Webpage					string `json:"webpage"`
}

type PublicHospitals []Hospital
