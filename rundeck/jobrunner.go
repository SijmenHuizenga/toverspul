package main

import (
	"golang.org/x/crypto/ssh"
	"time"
)

const (
	StatusOk                       = "OK"
	StatusStartupSshFailure        = "FAILURE_STARTUP_SSHKEY"
	StatusStartupConnectionFailure = "FAILURE_STARTUP_CONNECTION"
	StatusStartupSessionFailure    = "FAILURE_STARTUP_SESSION"
	StatusExecutionFailure         = "FAILURE_EXECUTION"
)

func RunCommandsOnServer(server Server, commands []string) (string, string, int64, int64) {
	start := time.Now().Unix()

	var hostKey ssh.PublicKey

	signer, err := ssh.ParsePrivateKey([]byte(server.PrivateKey))
	if err != nil {
		return err.Error(), StatusStartupSshFailure, start, time.Now().Unix()
	}

	sshConfig := &ssh.ClientConfig{
		User:            server.User,
		Auth:            []ssh.AuthMethod{ssh.PublicKeys(signer)},
		HostKeyCallback: ssh.FixedHostKey(hostKey),
	}
	sshConfig.HostKeyCallback = ssh.InsecureIgnoreHostKey()

	client, err := ssh.Dial("tcp", server.IpPort, sshConfig)
	if err != nil {
		return err.Error(), StatusStartupConnectionFailure, start, time.Now().Unix()
	}

	logs := ""

	for _, command := range commands {
		session, err := client.NewSession()

		if err != nil {
			client.Close()
			return err.Error(), StatusStartupSessionFailure, start, time.Now().Unix()
		}

		logs += "$ " + command + "\n"

		out, err := session.CombinedOutput(command)
		logs += string(out) + "\n\n"
		session.Close()

		if err != nil {
			logs += err.Error()
			return logs, StatusExecutionFailure, start, time.Now().Unix()
		}
	}

	return logs, StatusOk, start, time.Now().Unix()
}

func Any(vs []string, f func(string) bool) bool {
	for _, v := range vs {
		if f(v) {
			return true
		}
	}
	return false
}