all: compile compress

compile:
	go build -i -o toverspul-certbotbot

compress:
	upx --brute toverspul-certbotbot

dockerize:
	docker build -t sijmenhuizenga/randomapps:toverspul-certbotbot .

dockerun:
	docker run -v "${PWD}/config.yml":/certbotbot-config.yaml sijmenhuizenga/randomapps:toverspul-certbotbot

dockerpush:
	docker push sijmenhuizenga/randomapps:toverspul-certbotbot