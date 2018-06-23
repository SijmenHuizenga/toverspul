package main

import (
	"os/exec"
	"os"
	"log"
)

func dockerSwarmMaster(ip string){
	if cmdOk("docker", "node", "ls") {
		log.Println("Docker host already in swarm mode")
		return
	}
	log.Println("Docker host not yet in swarm.")

	if len(os.Args) == 3 {
		log.Println("Joining existing swarm...")
		cmdFailOnErrorPrintOutput("docker", "swarm", "join", "--token", os.Args[1], os.Args[2])
	}else {
		log.Println("Initializing new swarm...")
		cmdFailOnErrorPrintOutput("docker", "swarm", "init", "--advertise-addr", ip)
	}
}

func dockerSwarmMinion(){
	if cmdOk("bash", "-c", "docker info | grep \"Swarm: active\"") {
		log.Println("Docker host already in swarm mode")
		return
	}
	log.Println("Docker host not yet in swarm. Joining swarm...")

	if len(os.Args) != 3 {
		log.Fatal("Not enough cmd arguments to join.")
	}

	cmd := exec.Command("docker", "swarm", "join", "--token", os.Args[1], os.Args[2])
	output, err := cmd.Output()

	if err != nil {
		log.Fatal(err)
	}
	log.Print(string(output))
}