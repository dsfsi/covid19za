# I've decided to use a multi-stage docker build to allow for the posibility to add a front-end in the future
# This also ensures that the container we ship only contains productions code - (no build time dependencies)

# ---- Build the api ----
FROM golang:alpine AS apibuilder
WORKDIR $HOME/etc/api
COPY api/ ./
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix nocgo -o /api .

# ---- Final Image with api ----
FROM alpine:latest
FROM alpine:latest
RUN apk --no-cache add ca-certificates
COPY --from=apibuilder /api ./api
RUN chmod +x ./api
CMD ["./api"]