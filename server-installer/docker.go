package main

import (
	"log"
	"os/exec"
)

func docker(){
	packagename := "docker-ce"
	servicename := "docker"

	if packageInstalled(packagename) {
		log.Println("Docker package exists")
	}else {
		log.Println("Docker package doesn't exist, installing...")
		installDocker()
		log.Println("Docker installed")
	}

	if serviceEnabled(servicename) {
		log.Println("Docker service already enabled")
	}else {
		enableService(servicename)
		log.Println("Docker service enabled")
	}

	if serviceStarted(servicename) {
		log.Println("Docker service already started")
	}else {
		startService(servicename)
		log.Println("Docker service started")
	}
}

func installDocker(){
	output, err := exec.Command("curl", "-fsSL", "get.docker.com", "-o", "get-docker.sh").CombinedOutput()
	if err != nil {
		log.Fatal("Could not get docker installation script ", err, " " + string(output))
	}

	output2, err2 := exec.Command("sh", "get-docker.sh").CombinedOutput()
	if err2 != nil {
		log.Fatal("Failed running docker installation script ", err2, " " + string(output2))
	}
}