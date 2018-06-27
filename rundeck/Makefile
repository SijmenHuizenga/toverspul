all: compile compress

compile:
	go build -i -o toverspul-rundeck

run: compile
	./toverspul-rundeck

compress:
	upx --brute toverspul-rundeck