# COVID 19 Data REST API for South Africa
A RESTful API to expose the COVID 19 Data for South Africa created, maintained and hosted by DSFSI research group at the University of Pretoria

## Running the project

Before running the project API, you should set the `PORT` environmental variable on your computer `(e.g. PORT=1323)`

```bash
# Run
cd covid19za/api
go run main.go

# API Endpoint : http://127.0.0.1:1323
```

## API

The hosted API can be found on [https://covid-za-api.herokuapp.com](https://covid-za-api.herokuapp.com).

#### Authentication

There's no authentication required. Anybody and everybody is welcome to use this widely.

#### Rate limit

There is no rate limit of any kind but we hope that you use it in a sensible manner and whenever possible cache response for a few hours.


### Endpoints

#### /cases/confirmed
* `GET` : Get all confirmed cases

#### /cases/confirmed?province={province}
* `GET` : Get all confirmed cases in a province

#### /cases/deaths
* `GET` : Get all reported deaths

#### /cases/deaths?province={province}
* `GET` : Get all reported deaths in a province

#### /cases/timeline/tests
* `GET` : Get test timeline data 

#### /cases/timeline/provincial/cumulative
* `GET` : Get cumulative provincial timeline data

### Example Usage

You can get the confirmed cases by performing a `GET` request to:

```
https://covid-za-api.herokuapp.com/cases/confirmed
```

You can get the confirmed cases in Gauteng (`GP`) by performing a `GET` request to:

```
https://covid-za-api.herokuapp.com/cases/confirmed?province=GP
```

## Todo

- [x] Expose an endpoint to get all confirmed cases.
- [x] Allow filtering by province on the confirmed cases endpoint.
- [x] Expose an endpoint to get test timeline data.
- [x] Expose an endpoint to get all fatalities (reported deaths).
- [x] Allow filtering by province on the fatalities endpoint.
- [X] Expose an endpoint to get all available hospitals.
- [ ] Allow filtering by province on the hospitals endpoint.

## Issues

- [x] Expose an endpoint to get provincial cumulative timeline data [Issue #122].

