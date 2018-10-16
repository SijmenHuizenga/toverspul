package main

import (
	"github.com/smallfish/simpleyaml"
	"log"
	"strconv"
)

func loadConfig(data []byte) Config {
	y, err := simpleyaml.NewYaml(data)
	if err != nil {
		log.Fatal("Config file invalid syntax: " + err.Error())
	}

	email, err := y.Get("email").String()
	if err != nil {
		log.Fatal("Config file field email not found: " + err.Error())
	}

	httpport, err := y.Get("httpport").Int()
	if err != nil {
		log.Fatal("Config file field httpport not found: " + err.Error())
	}

	gcreds, err := y.Get("googlecredentialsfilepath").String()
	if err != nil {
		log.Fatal("Config file field googlecredentialsfilepath not found: " + err.Error())
	}

	cloudflarecreds, err := y.Get("cloudflarecredentialsfilepath").String()
	if err != nil {
		log.Fatal("Config file field cloudflarecredentialsfilepath not found: " + err.Error())
	}

	staging, err := y.Get("staging").Bool()
	if err != nil {
		log.Fatal("Config file field staging not found: " + err.Error())
	}

	dryrun, err := y.Get("dryrun").Bool()
	if err != nil {
		log.Fatal("Config file field dryrun not found: " + err.Error())
	}

	return Config{
		Email: email,
		HttpPort: strconv.Itoa(httpport),
		GoogleCredentialsFilePath: gcreds,
		CloudflareCredentialsFile: cloudflarecreds,
		Domains: loadDomainsConfig(y.Get("certs")),
		DryRun: dryrun,
		Staging: staging,
	}
}

func loadDomainsConfig(y *simpleyaml.Yaml) []CertConfig {
	if !y.IsArray() {
		log.Fatal("Config file invalid, certs not an array")
	}

	list, err := y.Array()
	if err != nil {
		log.Fatal("Config file invalid, could not make array: " + err.Error())
	}

	var config []CertConfig
	for _, configpart := range list {
		config = append(config, makeCertConfig(configpart))
	}
	return config
}

func makeCertConfig(configpart interface{}) CertConfig {
	m, ok := configpart.(map[interface{}]interface{})
	if !ok {
		log.Fatal("Config file invalid, cert is not a map")
	}

	return CertConfig{
		Name:       get(m, "name").(string),
		Domain:     get(m, "domain").(string),
		Challenge:  get(m, "challenge").(string),
		subdomains: toStrArr(get(m, "subdomains").([]interface{})),
	}
}

func get(dict map[interface{}]interface{}, key string) interface{} {
	if val, ok := dict[key]; ok {
		return val
	}
	log.Fatal("Config file invalid (5): field " + key + " not found")
	return nil
}

func toStrArr(in []interface{}) []string {
	var out []string
	for _, n := range in {
		out = append(out, n.(string))
	}
	return out
}
