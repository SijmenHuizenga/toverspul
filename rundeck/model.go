package main

import "gopkg.in/mgo.v2/bson"
import "github.com/ryanuber/go-glob"

type Config struct {
	MongoServer string
}

type Server struct {
	ID         bson.ObjectId `bson:"_id,omitempty"`
	Hostname   string	`json:"hostname"`
	IpPort     string	`json:"ipPort"`
	PrivateKey string	`json:"privateKey"`
	User       string	`json:"user"`
}

type Job struct {
	ID              bson.ObjectId `bson:"_id,omitempty",json:"id,omitempty"`
	Title			string		  `json:"title"`
	HostnamePattern string        `json:"hostnamePattern"`
	Commands        []string      `json:"commands"`
}

func (m Job) RunsOn(server Server) bool {
	return glob.Glob(m.HostnamePattern, server.Hostname)
}

type JobExecution struct {
	ID              bson.ObjectId `bson:"_id,omitempty"`
	StartTimestamp  int64
	FinishTimestamp int64
	Executions      []JobExecutionServer
}

type JobExecutionServer struct {
	Server          bson.ObjectId
	StartTimestamp  int64
	FinishTimestamp int64
	Logs            string
	Status          string
}
