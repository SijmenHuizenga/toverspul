package main

import "time"
import (
	"io/ioutil"
	"log"
	"os"
	"os/exec"
)

type Config struct {
	Email    string
	HttpPort string
	GoogleCredentialsFilePath string
	Domains  []CertConfig
}

type CertConfig struct {
	Domain     string
	Challenge  string
	subdomains []string
}

func main() {
	data, err := ioutil.ReadFile(os.Getenv("CONFIGFILE"))
	if err != nil {
		log.Fatal("Couldn't read config file '" + os.Getenv("CONFIGFILE") + "' " + err.Error())
	}

	config := loadConfig(data)

	log.Println("Loaded config: ", config)

	ticker := time.NewTicker(5 * time.Minute)
	checkUpdates(config)
	for {
		select {
		case <-ticker.C:
			checkUpdates(config)
		}
	}
}

func checkUpdates(config Config) {
	for _, domainConfig := range config.Domains {
		checkUpdate(domainConfig, config)
	}
}
func checkUpdate(domainConfig CertConfig, config Config) {
	log.Println("Checking updates for " + domainConfig.Domain)

	// check if directory exists in /etc/letsencrypt/live/
	// if exists than run the renew command for only this domain
	// else run the thing below

	args := []string{
		"certonly", "--dry-run", "--staging", "--non-interactive", "--agree-tos", "--email", config.Email,
		"-d", domainConfig.Domain,
	}

	for _, domain := range domainConfig.subdomains {
		args = append(args, "-d", domain)
	}

	switch domainConfig.Challenge {
	case "http":
		args = append(args, "--preferred-challenges", "http", "--http-01-port", config.HttpPort, "--standalone")
		break
	case "googledns":
		args = append(args, "--dns-google", "--dns-google-credentials", config.GoogleCredentialsFilePath)
		break
	default:
		log.Println("Challenge type " + domainConfig.Challenge + " not supported")
	}

	log.Println("$ certbot ", args)
	cmd := exec.Command("certbot", args...)
	output, err := cmd.CombinedOutput()
	log.Print(string(output))
	if err != nil {
		log.Println(err)
	}

	//make a pem file as described in (https://serversforhackers.com/c/letsencrypt-with-haproxy)

	//place it in a directory that is specified by some config property
}
