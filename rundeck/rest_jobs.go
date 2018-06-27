package main

import (
	"net/http"
	"encoding/json"
	"github.com/gorilla/mux"
	"fmt"
	"html"
	"gopkg.in/mgo.v2/bson"
)

func GetJobs(w http.ResponseWriter, r *http.Request) {
	var result []Job
	err := jobs.Find(nil).All(&result)
	if err != nil {
		failOnError(err, w)
	} else {
		if result == nil{
			okObj(w, [0]Job{})
		} else{
			okObj(w, result)
		}
	}
}

func GetJob(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)

	var result Job
	err := jobs.FindId(bson.ObjectIdHex(params["id"])).One(&result)
	if err != nil {
		failOnError(err, w)
	} else {
		okObj(w, result)
	}
}

func CreateJob(w http.ResponseWriter, r *http.Request) {
	var job Job
	err := json.NewDecoder(r.Body).Decode(&job)
	if err != nil {
		failOnError(err, w)
		return
	}

	err = jobs.Insert(job)
	if err != nil {
		failOnError(err, w)
	} else {
		okObj(w, job)
	}
}

func UpdateJob(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, `{"error": "Not implemented"}`)
}

func DeleteJob(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)
	err := jobs.RemoveId(bson.ObjectIdHex(params["id"]))
	if err != nil {
		failOnError(err, w)
	} else {
		ok(w)
	}
}

func failOnError(err error, w http.ResponseWriter) {
	w.WriteHeader(http.StatusInternalServerError)
	w.Write([]byte(`{"error": "`+ html.EscapeString(err.Error()) +`"}`))
}
func failNotFound(w http.ResponseWriter) {
	w.WriteHeader(http.StatusNotFound)
	w.Write([]byte(`{"error": "not found"}`))
}

func ok(w http.ResponseWriter) {
	w.WriteHeader(http.StatusOK)
}

func okObj(w http.ResponseWriter, element interface{}) {
	json.NewEncoder(w).Encode(element)
}
