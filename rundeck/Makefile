all: compile-backend compress-backend

compile-backend:
	go build -i -o toverspul-rundeck

run-backend: compile-backend
	./toverspul-rundeck

run-frontend:
	cd ui && npm start

compress-backend:
	upx --brute toverspul-rundeck