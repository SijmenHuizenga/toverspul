package main

import (
	"log"
	"strings"
)

func main() {
	if !isSudo() {
		log.Fatal("Must be run as sudo")
	}
	hostname := hostname()
	ip := privateNetIp()

	log.Println("Running on " + hostname + " with local ip " + ip)

	docker()
	dirs()
	if strings.HasPrefix(hostname, "master") {
		dockerSwarmMaster(ip)
	} else {
		dockerSwarmMinion()
	}
}
func dirs(){
	cmdFailOnErrorPrintOutput("mkdir", "/toverspul-data")
	cmdFailOnErrorPrintOutput("mkdir", "/toverspul-config")
}