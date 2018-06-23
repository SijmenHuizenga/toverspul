package main

import (
	"log"
	"strings"
	"os/exec"
)

func main() {
	if !isSudo() {
		log.Fatal("Must be run as sudo")
	}
	hostname := hostname()
	ip := privateNetIp()

	log.Println("Running on " + hostname + " with local ip " + ip)

	packages()
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
func packages(){
	output, err := exec.Command("apt-get", "install", "-y", "git").CombinedOutput()
	if err != nil {
		log.Fatal("Could not install some common packages ", err, " " + string(output))
	}
}