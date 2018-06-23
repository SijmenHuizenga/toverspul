package main

import (
	"os/exec"
	"log"
	"os"
	"path/filepath"
	"strings"
)

func main(){
	if len(os.Args) != 2 {
		log.Fatal("Usage: toverspul-swarm-deployer [dir]")
	}
	repodir := os.Args[1]

	updateStacks(repodir)
}

func updateStacks(repodir string){
	log.Println("Going through all directories in " + repodir + " looking for docker-compose.yml files")
	for _, folder := range findComposeFolders(repodir) {
		dockerStackDeploy(folder)
	}
	log.Println("Finished all deployments.")
}

func findComposeFolders(basedir string) []string {
	folders, err := filepath.Glob(basedir + "/*/docker-compose.yml")
	if err != nil {
		log.Fatal(err)
	}
	return Map(folders, func(s string) string {
		return s[:len(s) - len("/docker-compose.yml")]
	})
}

func dockerStackDeploy(composeFolder string){
	log.Println("stack deploying in dir " + composeFolder)
	cmd := exec.Command("docker", "stack", "deploy", "--prune", "--compose-file", "docker-compose.yml", projectName(composeFolder))
	cmd.Dir = composeFolder
	out, err := cmd.CombinedOutput()
	if err != nil {
		log.Println("stack deploy failed " + err.Error() + ": " + string(out))
		return
	}
	log.Println(string(out))
	log.Println("stack deployment success")
}

func projectName(composeFolder string) string{
	split := strings.Split(composeFolder, "/")
	return split[len(split)-1]
}

func Map(vs []string, f func(string) string) []string {
	vsm := make([]string, len(vs))
	for i, v := range vs {
		vsm[i] = f(v)
	}
	return vsm
}