# Builder
FROM golang:1.10 as builder

RUN mkdir /src
COPY main.go /src
WORKDIR /src
RUN go get -d -v
RUN go build -o /go/bin/dockup

FROM golang:1.10
COPY --from=builder /go/bin/dockup /go/bin/dockup
ENTRYPOINT ["/go/bin/dockup"]
