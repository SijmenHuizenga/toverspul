all: build

build:
	docker build -t toverspul-dockup .

#RUN FROM COMMAND LINE BECAUSE PWD WON'T WORK IN MAKEFILE
#dockerun:
#	docker run \
#		-v "$(pwd)/backup:/backup" \
#		-v "$(pwd)/passfile:/run/secrets/passfile" \
#		-v "$(pwd)/credentials:/run/secrets/aws-credentials" \
#		-v "/etc/hostname:/etc/hosthostname" \
#       -e CRON="* * * * *" \
#       -e BUCKET="toverspuldockup" \
#		toverspul-dockup