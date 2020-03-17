# COVID 19 Data REST API for South Africa
A RESTful API to expose the COVID 19 Data for South Africa created, maintained and hosted by DSFSI research group at the University of Pretoria

## Running the project

Before running the project API, you should set the `PORT` environmental variable on your computer `(e.g. PORT=1323)`

```bash
# Run
cd covid19za/api
go go run main.go

# API Endpoint : http://127.0.0.1:1323
```

## API

#### /cases/confirmed
* `GET` : Get all confirmed cases

## Todo

- [x] Expose an endpoint to get all confirmed cases.
- [ ] Expose an endpoint to get confirmed cases by province.
- [ ] Expose an endpoint to get all fatalities.
- [ ] Expose an endpoint to get all available hospitals.
- [ ] Expose an endpoint to get hospitals by province.