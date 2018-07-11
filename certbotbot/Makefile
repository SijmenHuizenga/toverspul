all: compile compress

compile:
	go build -i -o toverspul-certbotbot

compress:
	upx --brute toverspul-certbotbot

dockerize:
	docker build -t sijmenhuizenga/randomapps:toverspul-certbotbot .

dockerun:
	docker run -v "${PWD}/config.yml":/config.yml sijmenhuizenga/randomapps:toverspul-certbotbot