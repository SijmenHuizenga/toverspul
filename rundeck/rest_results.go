package main

import (
	"net/http"
)

func GetResults(w http.ResponseWriter, r *http.Request) {
	var result []JobExecution
	err := executions.Find(nil).Sort("-starttimestamp").Limit(5).All(&result)
	if err != nil {
		failOnError(err, w)
	} else {
		if result == nil{
			okObj(w, [0]JobExecution{})
		} else{
			okObj(w, result)
		}
	}
}

func GetResult(w http.ResponseWriter, r *http.Request) {
	executionId, err := param(r, "id")
	if err != nil {
		failOnError(err, w)
		return
	}

	var result JobExecution
	err = executions.FindId(executionId).One(&result)
	objOrErr(w, err, result)
}