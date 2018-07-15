all: build

build:
	docker build -t sijmenhuizenga/randomapps:toverspul-dockup .

run:
	docker run -v "$(pwd)/backup:/backup" -v "/etc/hostname:/etc/hostname-host" sijmenhuizenga/randomapps:toverspul-dockup

push:
	docker push sijmenhuizenga/randomapps:toverspul-dockup