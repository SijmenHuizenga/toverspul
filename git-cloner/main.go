package main

import (
	"os/exec"
	"log"
	"os"
)

func main(){
	if len(os.Args) != 3 {
		log.Fatal("Usage: toverspul-git-cloner [repodir] [repourl]")
	}
	repodir := os.Args[1]
	repourl := os.Args[2]

	updateRepo(repodir, repourl)
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