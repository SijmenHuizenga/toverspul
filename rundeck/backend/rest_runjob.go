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

	for _, server := range targetServers {
		serverResult := JobExecutionServer{
			Server: server,
		}
		serverResult.Server.PrivateKey = "***"

		execResults = append(execResults, serverResult)
	}

	for i, server := range targetServers {
		go func(i int, server Server) {
			defer wg.Done()
			logs, status, start, end := RunCommandsOnServer(server, exec.Job.Commands)

			execResults[i].Logs = logs
			execResults[i].StartTimestamp = start
			execResults[i].FinishTimestamp = end
			execResults[i].Status = status
		}(i, server)
	}

	wg.Wait()

	exec.FinishTimestamp = time.Now().Unix()
	exec.Executions = execResults
	executions.UpdateId(exec.ID, exec)

}