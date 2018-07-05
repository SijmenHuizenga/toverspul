package main

import (
	"os/exec"
	"log"
	"os"
	"path/filepath"
	"strings"
)

const currentlyDeployedDir = "/var/tmp/toverspul-currently-deployed"

func main() {
	if len(os.Args) != 2 {
		log.Fatal("Usage: toverspul-swarm-deployer [dir]")
	}
	repodir := os.Args[1]

	log.Println("Going through all directories in " + repodir + " looking for docker-compose.yml files")
	for _, projectFolder := range findProjectFolders(repodir) {
		projectName := projectName(projectFolder)
		log.Println("---- " + projectName + " ----")
		if isProjectConfigurationChanged(repodir, projectName) {
			dockerStackRemove(projectName)
			dockerStackDeploy(projectFolder, projectName)
		} else if isDockerComposeChanged(repodir, projectName) {
			dockerStackDeploy(projectFolder, projectName)
		} else {
			log.Println("No changes to configuration. Skipping project " + projectName)
		}
	}

	log.Println("---- ")
	copyDir(repodir, currentlyDeployedDir)
	log.Println("Finished all deployments.")
}

func copyDir(src string, target string) {
	os.RemoveAll(target)
	cmd := exec.Command("cp", "-R", src, target)
	out, err := cmd.CombinedOutput()
	if err != nil {
		log.Println("Failed to copy directory from " + src + " to " + target + ":" + err.Error())
		log.Print(string(out))
	}
}

func isProjectConfigurationChanged(repodir string, projectName string) bool {
	cmd := exec.Command("diff", "-qr", "-x", "docker-compose.yml", currentlyDeployedDir+"/"+projectName, repodir+"/"+projectName)
	out, err := cmd.CombinedOutput()
	if err == nil {
		log.Println("Deployment configuration of project " + projectName + " have not changed")
		return false
	} else {
		log.Println("Deployment configuration of project " + projectName + "has changed")
		log.Print(string(out))
		return true
	}
}

func isDockerComposeChanged(repodir string, projectName string) bool {
	cmd := exec.Command("diff", "-q", currentlyDeployedDir+"/"+projectName+"/docker-compose.yml", repodir+"/"+projectName+"/docker-compose.yml")
	out, err := cmd.CombinedOutput()
	if err == nil {
		log.Println("docker-compose.yml of project " + projectName + " have not changed")
		return false
	} else {
		log.Println("docker-compose.yml of project " + projectName + "has changed")
		log.Print(string(out))
		return true
	}
}

func findProjectFolders(basedir string) []string {
	folders, err := filepath.Glob(basedir + "/*/docker-compose.yml")
	if err != nil {
		log.Fatal(err)
	}
	return Map(folders, func(s string) string {
		return s[:len(s)-len("/docker-compose.yml")]
	})
}

func dockerStackRemove(projectName string) {
	log.Println("Removing stack " + projectName)
	cmd := exec.Command("docker", "stack", "rm", projectName)
	out, err := cmd.CombinedOutput()
	log.Print(string(out))
	if err != nil {
		log.Println("stack removal failed " + err.Error())
	} else {
		log.Println("stack removal success")
	}
}

func dockerStackDeploy(projectFolder string, projectName string) {
	log.Println("deploying stack in dir " + projectFolder)
	cmd := exec.Command("docker", "stack", "deploy", "--prune", "--compose-file", "docker-compose.yml", projectName)
	cmd.Dir = projectFolder
	out, err := cmd.CombinedOutput()
	log.Print(string(out))
	if err != nil {
		log.Println("stack deploy failed " + err.Error())
	} else {
		log.Println("stack deployment success")
	}
}

func projectName(composeFolder string) string {
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
