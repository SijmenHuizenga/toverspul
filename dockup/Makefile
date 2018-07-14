all: build

build:
	docker build -t toverspul-dockup .

run:
	docker run -v "$(pwd)/backup:/backup" -v "/etc/hostname:/etc/hostname-host" toverspul-dockup