all: compile compress dockerize

compile:
	CGO_ENABLED=0 go build -a -o toverspul-certbotbot

compress:
	upx --brute toverspul-certbotbot

dockerize:
	docker build -t sijmenhuizenga/randomapps:toverspul-certbotbot .

dockerun:
	docker run -p 80:80 -v "${PWD}/config.yml":/certbotbot-config.yaml sijmenhuizenga/randomapps:toverspul-certbotbot

dockerpush:
	docker push sijmenhuizenga/randomapps:toverspul-certbotbot