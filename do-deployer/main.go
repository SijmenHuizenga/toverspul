package main

import (
	"golang.org/x/oauth2"
	"github.com/digitalocean/godo"
	"context"
	"log"
	"os"
	"github.com/BurntSushi/toml"
)

func main() {
	config := ReadConfig()

	userdata := `#!/bin/bash
wget https://raw.githubusercontent.com/SijmenHuizenga/toverspul/master/server-installer/toverspul-server-installer -O /usr/local/bin/toverspul-server-installer
chmod +x /usr/local/bin/toverspul-server-installer
/usr/local/bin/toverspul-server-installer ` + config.SwarmToken + ` ` + config.SwarmIp + `

wget https://raw.githubusercontent.com/SijmenHuizenga/toverspul/master/git-cloner/toverspul-git-cloner -O /usr/local/bin/toverspul-git-cloner
chmod +x /usr/local/bin/toverspul-git-cloner
crontab -l | { cat; echo "*/14 * * * * /usr/local/bin/toverspul-git-cloner /toverspul-config https://github.com/SijmenHuizenga/toverspul-config.git >> /var/log/toverspul-git-cloner.log 2>&1"; } | crontab -
`

	key := godo.DropletCreateSSHKey{Fingerprint: config.DropletSShFingerprint}
	tokenSource := &TokenSource{AccessToken: config.DoToken}
	image := godo.DropletCreateImage{Slug: config.DropletImage}

	oauthClient := oauth2.NewClient(context.Background(), tokenSource)
	client := godo.NewClient(oauthClient)

	createRequest := &godo.DropletCreateRequest{
		Name:              config.DropletName,
		Region:            config.DropletRegion,
		Size:              config.DropletSize,
		SSHKeys:           []godo.DropletCreateSSHKey{key},
		Image:             image,
		PrivateNetworking: true,
		Monitoring:        true,
		Backups:           false,
		UserData:          userdata,
		Tags:              []string{"toverspul", config.DropletTag},
	}

	ctx := context.TODO()
	_, _, err := client.Droplets.Create(ctx, createRequest)

	if err != nil {
		log.Fatal(err)
	}
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
