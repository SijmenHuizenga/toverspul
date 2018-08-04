# Builder
FROM golang:1.10 as builder

RUN mkdir /src
ADD . /src
WORKDIR /src
RUN go get -d -v
ENV CGO_ENABLED=0
RUN go build -a -o /go/bin/certbotbot


# Actual image
FROM certbot/dns-google
COPY --from=builder /go/bin/certbotbot /usr/local/bin/toverspul-certbotbot
ENTRYPOINT ["/usr/local/bin/toverspul-certbotbot"]