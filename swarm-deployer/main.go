package main

import (
	"os/exec"
	"log"
	"os"
	"path/filepath"
	"strings"
)

func main(){
	if len(os.Args) != 3 {
		log.Fatal("Usage: toverspul-swarm-deployer [repodir] [repourl]")
	}
	repodir := os.Args[1]
	repourl := os.Args[2]

	updateRepo(repodir, repourl)
	updateStacks(repodir)
}

func updateStacks(repodir string){
	log.Println("Going through all directories in " + repodir + " looking for docker-compose.yml files")
	for _, folder := range findComposeFolders(repodir) {
		dockerStackDeploy(folder)
	}
	log.Println("Finished all deployments.")
}

func updateRepo(repodir string, repo string){
	log.Println("Checking if repo exists...")
	if fileNotExists(repodir) || !repoExists(repodir) {
		log.Println("Doesnt exist. Cloning repo " +repo+ " in " + repodir)
		exec.Command("mkdir", repodir).Run()
		clone(repo, repodir)
		log.Println("Repo cloned")
	} else {
		log.Println("Exists. Pulling from origin and resetting to origin/master")
		pullhard(repodir)
		log.Println("Pull success")
	}
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

func clone(repo string, dir string){
	cmd := exec.Command("git", "clone", repo, ".")
	cmd.Dir = dir
	output, err := cmd.CombinedOutput()
	log.Print(string(output))
	if err != nil {
		log.Fatal("git clone failed ", err)
	}
}

func pullhard(dir string){
	cmd := exec.Command("git", "--no-pager", "fetch", "origin")
	cmd.Dir = dir

	if out, err := cmd.CombinedOutput(); err != nil {
		log.Fatal("git fetch origin failed: " + err.Error() + ": " + string(out))
	}

	cmd2 := exec.Command("git", "--no-pager", "reset", "--hard", "origin/master")
	cmd2.Dir = dir

	if err := cmd2.Run(); err != nil {
		log.Fatal("git reset origin/master failed", err)
	}
}

func fileNotExists(dir string) bool{
	_, err := os.Stat(dir)
	return os.IsNotExist(err)
}

func repoExists(dir string) bool {
	cmd := exec.Command("git", "--no-pager", "status")
	cmd.Dir = dir
	err := cmd.Run()

	return err == nil
}

func Map(vs []string, f func(string) string) []string {
	vsm := make([]string, len(vs))
	for i, v := range vs {
		vsm[i] = f(v)
	}
	return vsm
}