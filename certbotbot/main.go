package main

import "time"
import (
	"io/ioutil"
	"log"
	"os/exec"
	"errors"
	"net/http"
	"fmt"
	"os"
)

const configFile = "/certbotbot-config.yaml"
const rootDir = "/certbotbot"
const certsDir = rootDir + "/certs"
const configDir = rootDir + "/le-config"
const workingDir = rootDir + "/le-work"
const logsDir = rootDir + "/le-logs"

type Config struct {
	Email                     string
	HttpPort                  string
	GoogleCredentialsFilePath string
	CloudflareCredentialsFile string
	Domains                   []CertConfig
	DryRun                    bool
	Staging                   bool
}

type CertConfig struct {
	Name       string
	Domain     string
	Challenge  string
	subdomains []string
}

func main() {
	config := loadConfig(readFile(configFile))

	log.Println("Loaded config: ", config)

	makeDirectories()

	setupHealthCheck()

	ticker := time.NewTicker(24 * time.Hour)
	checkUpdates(config)
	for {
		select {
		case <-ticker.C:
			checkUpdates(config)
		}
	}
}
func setupHealthCheck() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
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
	case "route53":
		args = append(args, "--dns-route53")
		break
	case "cloudflare":
		args = append(args, "--dns-cloudflare", "--dns-cloudflare-credentials", config.CloudflareCredentialsFile)
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
	pt2, e2 := ioutil.ReadFile(configDir + "/live/" + certname + "/privkey.pem")

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

func makeDirectories() {
	if _, err := os.Stat(rootDir); os.IsNotExist(err) {
		log.Fatal("Root config dir " + rootDir + " does not exist.")
	}
	if _, err := os.Stat(certsDir); os.IsNotExist(err) {
		err := os.Mkdir(certsDir, os.ModePerm)
		if err != nil {
			log.Fatal(err)
		}
	}
	if _, err := os.Stat(configDir); os.IsNotExist(err) {
		os.Mkdir(configDir, os.ModePerm)
		if err != nil {
			log.Fatal(err)
		}
	}
	if _, err := os.Stat(logsDir); os.IsNotExist(err) {
		os.Mkdir(logsDir, os.ModePerm)
		if err != nil {
			log.Fatal(err)
		}
	}
	if _, err := os.Stat(workingDir); os.IsNotExist(err) {
		os.Mkdir(workingDir, os.ModePerm)
		if err != nil {
			log.Fatal(err)
		}
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
