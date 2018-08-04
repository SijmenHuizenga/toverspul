FROM node as ui
ADD /ui /src
WORKDIR /src
RUN npm install
RUN npm run build

FROM golang:1.10 as backend
ADD backend /src
WORKDIR /src
RUN go get -d -v
RUN go build -o /go/bin/toverspul-rundeck

FROM debian
RUN mkdir /app
COPY --from=ui /src/dist /app/static
COPY --from=backend /go/bin/toverspul-rundeck /app/toverspul-rundeck
WORKDIR /app
ENV PORT "80"
EXPOSE 80
CMD ["./toverspul-rundeck"]