package models

type PrivateHospital struct {
	Id						string `json:"Id"`
	Name					string `json:"Name"`
	Longitude				string `json:"Longitude"`
	Latitude				string `json:"Latitude"`
	Province				string `json:"Province"`
}

type PrivateHospitals []PrivateHospital
