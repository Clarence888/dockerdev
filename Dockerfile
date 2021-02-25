# Compile stage
FROM golang:1.16.0 AS build-env

ENV GOPROXY=https://goproxy.cn,direct

# Build Delve
RUN go get github.com/go-delve/delve/cmd/dlv
RUN go get github.com/jackc/pgx/v4@v4.5.0

ADD . /dockerdev
WORKDIR /dockerdev
RUN go mod tidy
# Compile the application with the optimizations turned off
# This is important for the debugger to correctly work with the binary
RUN go build -gcflags "all=-N -l" -o /server

# Final stage
FROM debian:buster

EXPOSE 8000 40000

WORKDIR /
COPY --from=build-env /go/bin/dlv /
COPY --from=build-env /server /

CMD ["/dlv", "--listen=:40000", "--headless=true", "--api-version=2", "--accept-multiclient", "exec", "/server"]
