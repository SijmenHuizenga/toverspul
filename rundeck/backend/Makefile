all: compile compress

compile:
	go build -i -o toverspul-rundeck

run: compile
	MONGO_SERVER=localhost:27017 PORT=8090 ./toverspul-rundeck

compress:
	upx --brute toverspul-rundeck