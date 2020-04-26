package models

type PrivateHospital struct {
	Id        string `json:"Id" csv:"hospital_id"`
	Name      string `json:"Name" csv:"Hospital_name"`
	Longitude string `json:"Longitude" csv:"longitude"`
	Latitude  string `json:"Latitude" csv:"latitude"`
	Province  string `json:"Province" csv:"province"`
}

type PrivateHospitals []PrivateHospital
