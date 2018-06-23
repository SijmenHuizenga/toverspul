package main

import (
	"os/exec"
	"strconv"
	"github.com/xenolf/lego/log"
)

func removeLastChar(str string) string {
	return str[:len(str)-1]
}

func isSudo() bool {
	cmd := exec.Command("id", "-u")
	output, err := cmd.Output()

	if err != nil {
		return false
	}
	i, err := strconv.Atoi(string(output[:len(output)-1]))

	if err != nil {
		return false
	}

	return i == 0
}

func hostname() string {
	cmd := exec.Command("cat", "/etc/hostname")
	output, err := cmd.Output()

	if err != nil {
		log.Fatal(err)
	}

	return removeLastChar(string(output))
}

func cmdOk(name string, args ...string) bool{
	cmd := exec.Command(name, args...)
	err := cmd.Run()

	return err == nil
}

func cmdFailOnErrorPrintOutput(name string, args ...string) {
	cmd := exec.Command(name, args...)
	output, err := cmd.Output()

	if err != nil {
		log.Fatal(err)
	}
	log.Print(string(output))
}

func packageInstalled(packagename string) bool {
	return cmdOk("dpkg-query", "-l", packagename)
}

func serviceEnabled(servicename string) bool {
	return cmdOk("systemctl", "is-enabled", servicename)
}

func serviceStarted(servicename string ) bool {
	return cmdOk("systemctl", "is-active", "--quiet", servicename)
}

func enableService(servicename string) {
	cmd := exec.Command("systemctl", "enable", servicename)
	err := cmd.Run()
	if err != nil {
		log.Fatal("Could not enable " + servicename + " service", err)
	}
}

func startService(servicename string){
	cmd := exec.Command("systemctl", "start", servicename)
	err := cmd.Run()
	if err != nil {
		log.Fatal("Could not ename " + servicename + " service", err)
	}
}

func privateNetIp() string{
	cmd := exec.Command("bash", "-c", "ifconfig eth1 | sed -En -e 's/.*inet ([0-9.]+).*/\\1/p'")

	output, err := cmd.Output()

	if err != nil{
		log.Fatal(err)
	}
	if len(output) == 0 {
		log.Fatal("eth1 doesnt exist")
	}

	return removeLastChar(string(output))
}