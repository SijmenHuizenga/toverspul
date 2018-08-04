all: build

build:
	docker build -t toverspul-certbotbot .

run:
	docker run -p 80:80 -v "${PWD}/config.yml":/certbotbot-config.yaml toverspul-certbotbot
