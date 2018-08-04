all: build dockerbuild

build:
	go build -i -o dockup

dockerbuild:
	docker build -t sijmenhuizenga/randomapps:toverspul-dockup .

# run from cmd line

#dockerun:
#	docker run \
#		-v "$(pwd)/backup:/backup" \
#		-v "$(pwd)/passfile:/run/secrets/passfile" \
#		-v "$(pwd)/credentials:/run/secrets/aws-credentials" \
#       -e CRON="* * * * *" \
#       -e BUCKET="s3://toverspuldockup" \
#		sijmenhuizenga/randomapps:toverspul-dockup

dockerpush:
	docker push sijmenhuizenga/randomapps:toverspul-dockup