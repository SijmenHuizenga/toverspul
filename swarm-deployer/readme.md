Updates a docker swarm manager with new stack configuraitons from a git repo.

```bash
$ toverspul-swarm-deployer [repodir] [repourl]
```

Clones the repo the repo or fetches updates and resets hard to origin/master

Looks for all `docker-compose.yml` files in the repo and deploys tham as a stack. Everything is run from within the directory that contains the docker-compose yml.

### Installation
```bash
wget https://raw.githubusercontent.com/SijmenHuizenga/toverspul/master/swarm-deployer/toverspul-swarm-deployer -O /usr/local/bin/toverspul-swarm-deployer
chmod +x /usr/local/bin/toverspul-swarm-deployer
crontab -l | { cat; echo "*/15 * * * * /usr/local/bin/toverspul-swarm-deployer "/toverspul-config" "git@github.com:SijmenHuizenga/toverspul-config.git" > /var/log/toverspul-swarm-deployer.log"; } | crontab -
```