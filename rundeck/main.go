package main

import (
	"gopkg.in/mgo.v2"
	"log"
	"os"
	"github.com/BurntSushi/toml"
	"net/http"
	"github.com/gorilla/mux"
	"github.com/gorilla/handlers"
)

var servers *mgo.Collection
var jobs *mgo.Collection
var executions *mgo.Collection

func main() {
	config := ReadConfig()

	session, err := mgo.Dial(config.MongoServer)
	if err != nil {
		log.Fatal(err)
	}
	defer session.Close()

	db := session.DB("toverspul-rundeck")

	servers = db.C("servers")
	jobs = db.C("jobs")
	executions = db.C("executions")

	router := mux.NewRouter()
	router.HandleFunc("/run/{jobid}", RunJob).Methods("POST")
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

	log.Fatal(http.ListenAndServe(":8090", handlers.CORS(originsOk, headersOk, methodsOk)(router)))
}

func ReadConfig() Config {
	var configfile = "./settings.conf"
	_, err := os.Stat(configfile)
	if err != nil {
		log.Fatal("Config file is missing: ", configfile)
	}

	var config Config
	if _, err := toml.DecodeFile(configfile, &config); err != nil {
		log.Fatal(err)
	}
	return config
}