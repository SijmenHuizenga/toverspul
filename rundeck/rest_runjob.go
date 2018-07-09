package main

import (
	"net/http"
	"gopkg.in/mgo.v2/bson"
	"time"
	"sync"
)

func RunJob(w http.ResponseWriter, r *http.Request) {
	jobid, err := param(r, "jobid")
	if err != nil {
		failOnError(err, w)
		return
	}

	var job Job
	err = jobs.FindId(jobid).One(&job)
	if err != nil {
		failOnError(err, w)
		return
	}

	execution := JobExecution{
		ID:              bson.NewObjectId(),
		StartTimestamp:  time.Now().Unix(),
		Executions:      []JobExecutionServer{},
		FinishTimestamp: -1,
		Job:			 job,
	}

	var allServers []Server
	servers.Find(nil).All(&allServers)

	executions.Insert(execution)

	go execJob(execution, allServers)

	okObj(w, execution)
}

func execJob(exec JobExecution, availableServers []Server) {
	var targetServers []Server

	for _, server := range availableServers {
		if exec.Job.RunsOn(server) {
			targetServers = append(targetServers, server)
		}
	}

	var wg sync.WaitGroup
	wg.Add(len(targetServers))

	var execResults []JobExecutionServer
	for i, server := range targetServers {
		go func(i int, server Server) {
			defer wg.Done()
			execResults[i] = RunCommandsOnServer(server, exec.Job.Commands)
			exec.Executions = execResults
			executions.UpdateId(exec.ID, exec)
		}(i, server)
	}

	wg.Wait()
	exec.FinishTimestamp = time.Now().Unix()
	exec.Executions = execResults

	executions.UpdateId(exec.ID, exec)
}