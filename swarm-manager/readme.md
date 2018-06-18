Updates a docker swarm manager with new stack configuraitons from a git repo.

```
$ toverspul-swarm-manager [repourl] [repodir]
```

Clones the repo the repo or fetches updates and resets hard to origin/master

Looks for all `docker-compose.yml` files in the repo and deploys tham as a stack. Everything is run from within the directory that contains the docker-compose yml.