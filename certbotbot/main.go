package main

import "time"
import (
	"io/ioutil"
	"log"
	"os/exec"
	"errors"
	"net/http"
	"fmt"
)

const configFile = "/certbotbot-config.yaml"
const certsDir = "/certbotbot/certs"
const configDir = "/certbotbot/le-config"
const workingDir = "/certbotbot/le-work"
const logsDir = "/certbotbot/le-logs"

type Config struct {
	Email                     string
	HttpPort                  string
	GoogleCredentialsFilePath string
	Domains                   []CertConfig
	DryRun					  bool
	Staging					  bool
}

type CertConfig struct {
	Name 	   string
	Domain     string
	Challenge  string
	subdomains []string
}

func main() {
	config := loadConfig(readFile(configFile))

	log.Println("Loaded config: ", config)

	setupHealthCheck()

	ticker := time.NewTicker(5 * time.Minute)
	checkUpdates(config)
	for {
		select {
		case <-ticker.C:
			checkUpdates(config)
		}
	}
}
func setupHealthCheck() {
	http.HandleFunc("/", func (w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, "Hi there, I <3 certificates")
	})
	go func() {
		log.Fatal(http.ListenAndServe(":80", nil))
	}()
}

func checkUpdates(config Config) {
	for _, domainConfig := range config.Domains {
		checkUpdate(domainConfig, config)

		pem, err := getPem(domainConfig.Name)
		if err == nil {
			storePem(domainConfig.Name, pem)
		} else {
			log.Println(err)
		}
	}
}
func checkUpdate(domainConfig CertConfig, config Config) error {
	log.Println("Running certbot for " + domainConfig.Domain)

	// this set of commands creates a certificate if it doesnt exist.
	// updates it if it needs updating
	// if the cert exist but more subdomains are added than the cert is renewed to match the new domains
	args := []string{
		"certonly", "--non-interactive", "--agree-tos", "--renew-with-new-domains", "--expand",
		"--config-dir", configDir,
		"--work-dir", workingDir,
		"--logs-dir", logsDir,
		"--email", config.Email,
		"--cert-name", domainConfig.Name,
		"-d", domainConfig.Domain,
	}

	if config.DryRun {
		args = append(args, "--dry-run")
	}

	if config.Staging {
		args = append(args, "--staging")
	} else {
		args = append(args, "--server", "https://acme-v02.api.letsencrypt.org/directory")
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
		return errors.New("Challenge type " + domainConfig.Challenge + " not supported")
	}

	log.Println("$ certbot ", args)
	cmd := exec.Command("certbot", args...)
	output, err := cmd.CombinedOutput()
	log.Print(string(output))
	return err
}

func getPem(certname string) (string, error) {
	pt1, e1 := ioutil.ReadFile(configDir + "/live/" + certname + "/fullchain.pem")
	pt2, e2 := ioutil.ReadFile(configDir +  "/live/" + certname + "/privkey.pem")

	if e1 != nil || e2 != nil {
		return "", errors.New(e1.Error() + " | " + e2.Error())
	}

	return string(pt1) + string(pt2), nil
}

func storePem(certname string, pem string) {
	filename := certsDir + "/" + certname + ".pem"
	err := ioutil.WriteFile(filename, []byte(pem), 0644)
	if err != nil {
		log.Println("ERROR: Couldn't write pem file '" + filename + "': " + err.Error())
	}
}

func readFile(filename string) []byte {
	data, err := ioutil.ReadFile(filename)
	if err != nil {
		log.Println("ERROR: Couldn't read file '" + filename + "': " + err.Error())
		return []byte{}
	}
	return data
}
