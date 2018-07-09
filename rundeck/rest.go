package main

import (
	"net/http"
	"encoding/json"
	"html"
)

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
func objOrErr(w http.ResponseWriter, err error, obj interface{}){
	if err != nil {
		failOnError(err, w)
	} else {
		okObj(w, obj)
	}
}
func okOrErr(w http.ResponseWriter, err error){
	if err != nil {
		failOnError(err, w)
	} else {
		ok(w)
	}
}
