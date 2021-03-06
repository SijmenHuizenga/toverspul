package main

import (
	"net/http"
	"encoding/json"
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
	id, err := param(r, "id")
	if err != nil {
		failOnError(err, w)
		return
	}

	var result Job
	err = jobs.FindId(id).One(&result)
	objOrErr(w, err, result)
}

func CreateJob(w http.ResponseWriter, r *http.Request) {
	var job Job
	err := json.NewDecoder(r.Body).Decode(&job)
	if err != nil {
		failOnError(err, w)
		return
	}
	job.ID = bson.NewObjectId()

	err = jobs.Insert(job)
	objOrErr(w, err, job)
}

func UpdateJob(w http.ResponseWriter, r *http.Request) {
	id, err := param(r, "id")
	if err != nil {
		failOnError(err, w)
		return
	}

	var job Job
	err = json.NewDecoder(r.Body).Decode(&job)
	if err != nil {
		failOnError(err, w)
		return
	}

	err = jobs.UpdateId(id, job)
	objOrErr(w, err, job)
}

func DeleteJob(w http.ResponseWriter, r *http.Request) {
	id, err := param(r, "id")
	if err != nil {
		failOnError(err, w)
		return
	}

	var result Job
	err = jobs.FindId(id).One(&result)
	if err != nil {
		failOnError(err, w)
		return
	}
	err2 := jobs.RemoveId(id)
	objOrErr(w, err2, result)
}

