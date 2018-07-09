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

func RunCommandsOnServer(server Server, commands []string) JobExecutionServer {
	start := time.Now().Unix()

	var hostKey ssh.PublicKey

	signer, err := ssh.ParsePrivateKey([]byte(server.PrivateKey))
	if err != nil {
		return result(err.Error(), StatusStartupSshFailure, start, server)
	}

	sshConfig := &ssh.ClientConfig{
		User:            server.User,
		Auth:            []ssh.AuthMethod{ssh.PublicKeys(signer)},
		HostKeyCallback: ssh.FixedHostKey(hostKey),
	}
	sshConfig.HostKeyCallback = ssh.InsecureIgnoreHostKey()

	client, err := ssh.Dial("tcp", server.IpPort, sshConfig)
	if err != nil {
		return result(err.Error(), StatusStartupConnectionFailure, start, server)
	}

	session, err := client.NewSession()
	defer client.Close()

	if err != nil {
		return result(err.Error(), StatusStartupSessionFailure, start, server)
	}

	logs := ""

	for _, command := range commands {
		logs += "$ " + command + "\n"
		out, err := session.CombinedOutput(command)
		logs += string(out) + "\n\n"
		if err != nil {
			logs += err.Error()
			return result(logs, StatusExecutionFailure, start, server)
		}
	}

	return result(logs, StatusOk, start, server)
}

func result(logs string, status string, startTimestamp int64, server Server) JobExecutionServer {
	return JobExecutionServer{
		Logs: logs,
		Status: status,
		StartTimestamp: startTimestamp,
		FinishTimestamp: time.Now().Unix(),
		Server: server.ID,
	}
}

func Any(vs []string, f func(string) bool) bool {
	for _, v := range vs {
		if f(v) {
			return true
		}
	}
	return false
}