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


	//servers.Insert(Server{Hostname: "hostname", IpPort: "ipport", Privatekey: "privatekey", User: "user"})
	//
	//var results []Server
	//err = servers.Find(bson.M{}).All(&results)
	//
	//for _, result := range results {
	//	log.Println(result.ID)
	//}

	router := mux.NewRouter()
	router.HandleFunc("/jobs/{id}", GetJob).Methods("GET")
	router.HandleFunc("/jobs/{id}", UpdateJob).Methods("PUT")
	router.HandleFunc("/jobs/{id}", DeleteJob).Methods("DELETE")
	router.HandleFunc("/jobs", GetJobs).Methods("GET")
	router.HandleFunc("/jobs", CreateJob).Methods("POST")
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