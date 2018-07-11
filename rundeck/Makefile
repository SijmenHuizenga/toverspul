all: compile combine

publish: all dockerize dockerpush

compile:
	cd ui && make
	cd backend && make

combine:
	rm -rf dist
	mkdir dist
	cp backend/toverspul-rundeck dist/toverspul-rundeck
	mkdir dist/static
	cp -r ui/dist/* dist/static/

dockerize:
	cd dist && docker build -t sijmenhuizenga/randomapps:toverspul-rundeck -f ../Dockerfile .

dockerun:
	docker-compose up

dockerpush:
	docker push sijmenhuizenga/randomapps:toverspul-rundeck