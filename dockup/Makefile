all: build dockerbuild

build:
	go build -i -o dockup

dockerbuild:
	docker build -t sijmenhuizenga/randomapps:toverspul-dockup .

#RUN FROM COMMAND LINE BECAUSE PWD WON'T WORK IN MAKEFILE
#dockerun:
#	docker run \
#		-v "$(pwd)/backup:/backup" \
#		-v "$(pwd)/passfile:/run/secrets/passfile" \
#		-v "$(pwd)/credentials:/run/secrets/aws-credentials" \
#		-v "/etc/hostname:/etc/hosthostname" \
#       -e CRON="* * * * *" \
#       -e BUCKET="toverspuldockup" \
#		sijmenhuizenga/randomapps:toverspul-dockup

dockerpush:
	docker push sijmenhuizenga/randomapps:toverspul-dockup