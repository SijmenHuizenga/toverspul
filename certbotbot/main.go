package main

import "time"
import (
	"io/ioutil"
	"log"
	"os/exec"
	"errors"
)

type Config struct {
	Email                     string
	HttpPort                  string
	GoogleCredentialsFilePath string
	Domains                   []CertConfig
}

type CertConfig struct {
	Domain     string
	Challenge  string
	subdomains []string
}

func main() {
	config := loadConfig(readFile("/certbotbot-config.yaml"))

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

		pem, err := getPem(domainConfig.Domain)
		if err == nil {
			storePem(domainConfig.Domain, pem)
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
		"certonly", "--dry-run", "--staging", "--non-interactive", "--agree-tos", "--renew-with-new-domains", "--expand",
		"--config-dir", "/certbotbot/le-config",
		"--work-dir", "/certbotbot/le-work",
		"--logs-dir", "/certbotbot/le-logs",
		"--email", config.Email,
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
		return errors.New("Challenge type " + domainConfig.Challenge + " not supported")
	}

	log.Println("$ certbot ", args)
	cmd := exec.Command("certbot", args...)
	output, err := cmd.CombinedOutput()
	log.Print(string(output))
	return err
}

func getPem(domain string) (string, error) {
	pt1, e1 := ioutil.ReadFile("/etc/letsencrypt/live/" + domain + "/fullchain.pem")
	pt2, e2 := ioutil.ReadFile("/etc/letsencrypt/live/" + domain + "/privkey.pem")

	if e1 != nil || e2 != nil {
		return "", errors.New(e1.Error() + " | " + e2.Error())
	}

	return string(pt1) + string(pt2), nil
}

func storePem(domain string, pem string) {
	filename := "/certbotbot/certs/" + domain + ".pem"
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
