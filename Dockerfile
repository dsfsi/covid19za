# I've decided to use a multi-stage docker build to allow for the posibility to add a front-end in the future
# This also ensures that the container we ship only contains productions code - (no build time dependencies)

# ---- Build the api ----
FROM golang:alpine AS apibuilder
WORKDIR $HOME/etc/api
# Start by copying just the parts needed for go mod download, so that source
# changes don't trigger re-download.
COPY api/go.mod ./go.mod
COPY api/go.sum ./go.sum
RUN go mod download
COPY api/ ./
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix nocgo -o /api .

# ---- Final Image with api and varnish ----
# bash, curl, openssh and python are for Heroku's ssh tunnel
FROM alpine:latest
RUN apk --no-cache add ca-certificates varnish supervisor bash curl openssh python
COPY docker/heroku-exec.sh /app/.profile.d/
RUN ln -sf /bin/bash /bin/sh
COPY docker/supervisord.conf /etc/supervisord.conf
COPY docker/varnish/default.vcl /etc/varnish/default.vcl
COPY --from=apibuilder /api ./api
RUN chmod +x ./api
# Heroku runs Docker containers as non-root user, so do the same locally for
# testing.
RUN adduser -D apiuser
RUN chown -R apiuser /var/lib/varnish /etc/varnish
USER apiuser
CMD ["/usr/bin/supervisord"]
