package main

import (
	"gopkg.in/mgo.v2"
	"log"
	"os"
	"net/http"
	"github.com/gorilla/mux"
	"github.com/gorilla/handlers"
	"strings"
)

var servers *mgo.Collection
var jobs *mgo.Collection
var executions *mgo.Collection

func main() {
	port := os.Getenv("PORT")
	mongoServer := os.Getenv("MONGO_SERVER")
	if strings.TrimSpace(port) == "" {
		log.Fatal("Port not provided")
	}

	session, err := mgo.Dial(mongoServer)
	if err != nil {
		log.Fatal(err)
	}
	defer session.Close()

	db := session.DB("toverspul-rundeck")

	servers = db.C("servers")
	jobs = db.C("jobs")
	executions = db.C("executions")

	router := mux.NewRouter()
	router.HandleFunc("/run/{jobid}", RunJob).Methods("GET")
	router.HandleFunc("/results", GetResults).Methods("GET")
	router.HandleFunc("/results/{id}", GetResult).Methods("GET")

	router.HandleFunc("/jobs/{id}", GetJob).Methods("GET")
	router.HandleFunc("/jobs/{id}", UpdateJob).Methods("PUT")
	router.HandleFunc("/jobs/{id}", DeleteJob).Methods("DELETE")
	router.HandleFunc("/jobs", GetJobs).Methods("GET")
	router.HandleFunc("/jobs", CreateJob).Methods("POST")

	router.HandleFunc("/servers/{id}", GetServer).Methods("GET")
	router.HandleFunc("/servers/{id}", UpdateServer).Methods("PUT")
	router.HandleFunc("/servers/{id}", DeleteServer).Methods("DELETE")
	router.HandleFunc("/servers", GetServers).Methods("GET")
	router.HandleFunc("/servers", CreateServer).Methods("POST")


	router.PathPrefix("/").Handler(http.FileServer(http.Dir("./static/")))

	headersOk := handlers.AllowedHeaders([]string{"X-Requested-With", "Content-Type"})
	originsOk := handlers.AllowedOrigins([]string{"*"})
	methodsOk := handlers.AllowedMethods([]string{"GET", "HEAD", "POST", "PUT", "DELETE", "OPTIONS"})

	log.Println("Starting server on :"+port)

	log.Fatal(http.ListenAndServe(":"+port, handlers.CORS(originsOk, headersOk, methodsOk)(router)))
}