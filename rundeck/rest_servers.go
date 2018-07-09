package main

import (
	"net/http"
	"encoding/json"
	"gopkg.in/mgo.v2/bson"
)

func GetServers(w http.ResponseWriter, r *http.Request) {
	var result []Server
	err := servers.Find(nil).All(&result)
	if err != nil {
		failOnError(err, w)
	} else {
		if result == nil{
			okObj(w, [0]Server{})
		} else{
			okObj(w, result)
		}
	}
}

func GetServer(w http.ResponseWriter, r *http.Request) {
	id, err := param(r, "id")
	if err != nil {
		failOnError(err, w)
		return
	}

	var result Server
	err = servers.FindId(id).One(&result)
	objOrErr(w, err, result)
}

func CreateServer(w http.ResponseWriter, r *http.Request) {
	var server Server
	err := json.NewDecoder(r.Body).Decode(&server)
	if err != nil {
		failOnError(err, w)
		return
	}
	server.ID = bson.NewObjectId()

	err = servers.Insert(server)
	objOrErr(w, err, server)
}

func UpdateServer(w http.ResponseWriter, r *http.Request) {
	id, err := param(r, "id")
	if err != nil {
		failOnError(err, w)
		return
	}

	var server Server
	err = json.NewDecoder(r.Body).Decode(&server)
	if err != nil {
		failOnError(err, w)
		return
	}

	err = servers.UpdateId(id, server)
	objOrErr(w, err, server)
}

func DeleteServer(w http.ResponseWriter, r *http.Request) {
	id, err := param(r, "id")
	if err != nil {
		failOnError(err, w)
		return
	}

	var result Server
	err = servers.FindId(id).One(&result)
	if err != nil {
		failOnError(err, w)
		return
	}
	err2 := servers.RemoveId(id)
	objOrErr(w, err2, result)
}