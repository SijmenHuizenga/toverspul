package main

import (
	"golang.org/x/oauth2"
	"log"
	"os"
	"github.com/BurntSushi/toml"
	"github.com/digitalocean/godo"
	"context"
	"io/ioutil"
	"os/exec"
)

func main() {
	config := ReadConfig()

	userdata := `#!/bin/bash
wget https://raw.githubusercontent.com/SijmenHuizenga/toverspul/master/server-installer/toverspul-server-installer -O /usr/local/bin/toverspul-server-installer
chmod +x /usr/local/bin/toverspul-server-installer
/usr/local/bin/toverspul-server-installer ` + config.SwarmToken + ` ` + config.SwarmIp + `

wget https://raw.githubusercontent.com/SijmenHuizenga/toverspul/master/git-cloner/toverspul-git-cloner -O /usr/local/bin/toverspul-git-cloner
chmod +x /usr/local/bin/toverspul-git-cloner
`
	tokenSource := &TokenSource{AccessToken: config.DoToken}
	oauthClient := oauth2.NewClient(context.Background(), tokenSource)
	client := godo.NewClient(oauthClient)
	ctx := context.TODO()

	serverPubKey := makeKeypair(config.DropletName)
	serverPubKeyRequest := godo.KeyCreateRequest{
		Name: "toverspul-rundeck-" + config.DropletName,
		PublicKey: serverPubKey,
	}
	serverKey, _, err := client.Keys.Create(ctx, &serverPubKeyRequest)

	if err != nil {
		log.Fatal(err)
	}

	createRequest := &godo.DropletCreateRequest{
		Name:              config.DropletName,
		Region:            config.DropletRegion,
		Size:              config.DropletSize,
		SSHKeys:           []godo.DropletCreateSSHKey{
			{Fingerprint: config.DropletSShFingerprint},
			{Fingerprint: serverKey.Fingerprint},
		},
		Image:             godo.DropletCreateImage{Slug: config.DropletImage},
		PrivateNetworking: true,
		Monitoring:        true,
		Backups:           false,
		UserData:          userdata,
		Tags:              []string{"toverspul", config.DropletTag},
	}


	droplet, _, err := client.Droplets.Create(ctx, createRequest)

	if err != nil {
		log.Fatal(err)
	}

	log.Println("Droplet " + droplet.Name + " created.")
}

type TokenSource struct {
	AccessToken string
}

func (t *TokenSource) Token() (*oauth2.Token, error) {
	token := &oauth2.Token{
		AccessToken: t.AccessToken,
	}
	return token, nil
}

type Config struct {
	DropletName           string
	DropletRegion         string
	DropletSize           string
	DropletSShFingerprint string
	DropletTag            string
	DropletImage          string
	SwarmIp               string
	SwarmToken            string
	DoToken               string
}

func makeKeypair(hostname string) string {
	keyfile := os.Getenv("HOME") + "/.ssh/toverspul/rundeck-" + hostname

	if _, err := os.Stat(keyfile + ".pub"); err == nil {
		log.Println("keyfile " + keyfile + " already exist. Using existing public key")
	} else {
		cm := exec.Command("ssh-keygen", "-t", "rsa", "-b", "4096", "-C", "rundeck@"+hostname, "-N", "", "-f", keyfile)
		out, err := cm.CombinedOutput()
		if err != nil {
			log.Println(string(out))
			log.Fatal("ssh-keygen failed: ", err)
		}
		log.Println("Private key for this server generated and be found in " + keyfile)
	}

	pubKey, err := ioutil.ReadFile(keyfile + ".pub")
	if err != nil {
		log.Fatal("pub key could not be read ", err)
	}
	return string(pubKey)
}

func ReadConfig() Config {
	var configfile = "./settings.conf"
	_, err := os.Stat(configfile)
	if err != nil {
		log.Fatal("Config file is missing: ", configfile)
	}

	var config Config
	if _, err := toml.DecodeFile(configfile, &config); err != nil {
		log.Fatal(err)
	}
	return config
}
