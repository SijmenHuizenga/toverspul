Initializes a new Digital Ocean server to be part of the toverspul platform. Run as follows:

```
$ toverspul-server-installer (swarm-token) (swarm-managerip:port)
```

Installs docker if it isn't installed.

Enables and starts the docker service if it isn't enabled or started.

If the hostname starts with `master` it tries to become a docker swarm manager if it is not yet one. If no arguments are supplied a new swarm is created. Else a existing swarm is joined using the token and ip:port.

If the hostname doesn't start with `master` it tries to joins a docker swarm if it isn't part of one already. It uses parameter 1 as the token and parameter 2 as the ip:port. 


### User Data
```
#!/bin/bash

wget https://raw.githubusercontent.com/SijmenHuizenga/toverspul/master/server-installer/toverspul-server-installer -O /usr/local/bin/toverspul-server-installer
chmod +x /usr/local/bin/toverspul-server-installer
/usr/local/bin/toverspul-server-installer (TOKEN) (IP:PORT)
```