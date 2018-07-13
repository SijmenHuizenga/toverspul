Creates a new Digital Ocean droplet and configures it to be part of a toverspul network. It uses a configuration file `./settings.conf` to receive information about the droplet to create.

```toml
DropletName = "app1"
DropletRegion = "ams3"
DropletSize = "s-1vcpu-1gb"
DropletSShFingerprint = "d1:e0:d4:73:7a:c7:72:a9:b3:2c:73:45:48:e3:ab:db"
DropletTag = "app"
DropletImage = "debian-9-x64"
SwarmIp = "[internal swarm ip + port]"
SwarmToken = "[swarm manager or worker token]"
DoToken = "[digitalocean api key token]"
```

 