all: run

build:
	docker build -t toverspul-dockup .

build-decryptor:
	go build decrypt.go

run:
	docker-compose up --build
