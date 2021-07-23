package main

import (
	"encoding/json"
	"github.com/labstack/echo"
	"github.com/stretchr/testify/assert"
	"net/http"
	"net/http/httptest"
	"reflect"
	"testing"
)

var (
	expectedPublicHospital = map[string]interface{}{
		"Id":                    "1",
		"Name":                  "Addington Hospital",
		"Long":                  "31.042291",
		"Lat":                   "-29.8616",
		"Category":              "Public Hospital",
		"Province":              "KwaZuluNatal",
		"district":              "eThekwini Metropolitan Municipality",
		"Subdistrict":           "eThekwini MM Sub",
		"DistrictEstPopulation": "3702231",
		"GeoSubdivision":        "ZA-KZN",
	}
	expectedPrivateHospital = map[string]interface{}{
		"Id":        "464",
		"Name":      "Mediclinic Newcastle Day Hospital",
		"Longitude": "29.931891",
		"Latitude":  "-27.7672",
		"Province":  "ZA-KZN",
	}
	expectedConfirmedCase = map[string]interface{}{
		"case_id":           "2",
		"date":              "07-03-2020",
		"timestamp":         "20200307",
		"country":           "South Africa",
		"validators":        "GP",
		"geo_subdivision":   "ZA-GP",
		"age":               "39",
		"gender":            "female",
		"transmission_type": "Travelled to Italy",
	}
	expectedReportedDeath = map[string]interface{}{
		"report_id":       "4",
		"date":            "31-03-2020",
		"timestamp":       "20200331",
		"province":        "GP",
		"geo_subdivision": "ZA-GP",
		"gender":          "male",
		"age":             "79",
		"notes":           "presented with respiratory distress",
		"source":          "https://sacoronavirus.co.za/2020/03/31/update-of-covid-19-31st-march-2020/",
	}
	// No single object has all fields populated, so use several. Missing data
	// are removed from the expected records so that the test will not fail if
	// they are provided later.
	expectedTests = []map[string]interface{}{
		map[string]interface{}{
			"date":             "27-03-2020",
			"timestamp":        "20200327",
			"cumulative_tests": "28537",
			"hospitalisation":  "55",
			"critical_icu":     "4",
			"ventilation":      "3",
			"deaths":           "1",
			"contacts": map[string]interface{}{
				"contacts_identified": "4407",
				"contacts_traced":     "3645",
			},
		},
		map[string]interface{}{
			"date":             "14-03-2020",
			"timestamp":        "20200314",
			"cumulative_tests": "1017",
			"critical_icu":     "0",
			"ventilation":      "0",
			"deaths":           "0",
			"travellers": map[string]interface{}{
				"scanned":                  "28087",
				"elevated_temperature":     "0",
				"covid_suspected_criteria": "0",
			},
		},
		map[string]interface{}{
			"date":             "18-04-2020",
			"timestamp":        "20200418",
			"cumulative_tests": "108201",
			"recovered":        "",
			"hospitalisation":  "241",
			"critical_icu":     "36",
			"ventilation":      "26",
			"deaths":           "52",
		},
	}
	expectedCumulativeProvincial = map[string]interface{}{
		"timestamp": "20200418",
		"date":      "18-04-2020",
		"provinces": map[string]interface{}{
			"eastern_cape":  "270",
			"free_state":    "100",
			"gauteng":       "1101",
			"kwazulu_natal": "604",
			"limpopo":       "26",
			"mpumlanga":     "25", // It is misspelt like this in the API
			"northern_cape": "16",
			"north_west":    "24",
			"western_cape":  "836",
			"unknown":       "32",
		},
		"total": "3034",
	}
)

func TestRoot(t *testing.T) {
	response := request(httptest.NewRequest(http.MethodGet, "/", nil))
	assert.Equal(t, http.StatusOK, response.StatusCode)
	assert.Equal(t, echo.MIMETextPlainCharsetUTF8, response.Header["Content-Type"][0])
}

func TestPublicHospitals(t *testing.T) {
	data, ok := requestJSON(t, httptest.NewRequest(http.MethodGet, "/hospitals/public", nil))
	if ok {
		assertContains(t, data, expectedPublicHospital)
	}
}

func TestPrivateHospitals(t *testing.T) {
	data, ok := requestJSON(t, httptest.NewRequest(http.MethodGet, "/hospitals/private", nil))
	if ok {
		assertContains(t, data, expectedPrivateHospital)
	}
}

func TestAllConfirmedCases(t *testing.T) {
	data, ok := requestJSON(t, httptest.NewRequest(http.MethodGet, "/cases/confirmed", nil))
	if ok {
		assertContains(t, data, expectedConfirmedCase)
	}
}

func TestAllConfirmedCasesFilterProvince(t *testing.T) {
	data, ok := requestJSON(t, httptest.NewRequest(http.MethodGet, "/cases/confirmed?province=GP", nil))
	if ok {
		assertContains(t, data, expectedConfirmedCase)
		for _, row := range data {
			assert.Equal(t, "GP", row["validators"])
			assert.Equal(t, "ZA-GP", row["geo_subdivision"])
		}
	}
}

func TestAllConfirmedCasesBadProvince(t *testing.T) {
	response := request(httptest.NewRequest(http.MethodGet, "/cases/confirmed?province=BAD", nil))
	assert.Equal(t, http.StatusBadRequest, response.StatusCode)
}

func TestAllReportedDeaths(t *testing.T) {
	data, ok := requestJSON(t, httptest.NewRequest(http.MethodGet, "/cases/deaths", nil))
	if ok {
		assertContains(t, data, expectedReportedDeath)
	}
}

func TestAllReportedDeathsFilterProvince(t *testing.T) {
	data, ok := requestJSON(t, httptest.NewRequest(http.MethodGet, "/cases/deaths?province=GP", nil))
	if ok {
		assertContains(t, data, expectedReportedDeath)
		for _, row := range data {
			assert.Equal(t, "GP", row["province"])
			assert.Equal(t, "ZA-GP", row["geo_subdivision"])
		}
	}
}

func TestAllReportedDeathsBadProvince(t *testing.T) {
	response := request(httptest.NewRequest(http.MethodGet, "/cases/deaths?province=BAD", nil))
	assert.Equal(t, http.StatusBadRequest, response.StatusCode)
}

func TestTestingTimeline(t *testing.T) {
	data, ok := requestJSON(t, httptest.NewRequest(http.MethodGet, "/cases/timeline/tests", nil))
	if ok {
		for _, expected := range expectedTests {
			assertContains(t, data, expected)
		}
	}
}

func TestCumulativeProvincialTimeline(t *testing.T) {
	data, ok := requestJSON(t, httptest.NewRequest(http.MethodGet, "/cases/timeline/provincial/cumulative", nil))
	if ok {
		assertContains(t, data, expectedCumulativeProvincial)
	}
}

// Check that the JSON response contains a given record. The response may also
// contain extra fields.
func assertContains(t *testing.T, data []map[string]interface{},
	expected map[string]interface{}) bool {
	found := false
	for _, row := range data {
		match := true
		for field, value := range expected {
			if !reflect.DeepEqual(row[field], value) {
				match = false
			}
		}
		if match {
			found = true
			break
		}
	}
	return assert.True(t, found, "The expected record was not found")
}

func request(req *http.Request) *http.Response {
	e := makeAPI("../data/")
	rec := httptest.NewRecorder()
	e.ServeHTTP(rec, req)
	return rec.Result()
}

// Retrieve a request and convert it to a JSON array of objects. The
// second parameter is true on success, false on error (the error is
// reported through the testing interface.
func requestJSON(t *testing.T, req *http.Request) ([]map[string]interface{}, bool) {
	response := request(req)
	if !assert.Equal(t, http.StatusOK, response.StatusCode) {
		return nil, false
	}
	assert.Equal(t, echo.MIMEApplicationJSONCharsetUTF8, response.Header["Content-Type"][0])
	var data []map[string]interface{}
	err := json.NewDecoder(response.Body).Decode(&data)
	if !assert.NoError(t, err) {
		return nil, false
	}
	return data, true
}
