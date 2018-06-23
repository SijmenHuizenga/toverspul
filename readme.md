## Toverspul Platform

Infrastructure tools that run my personal swarm cluster. This project is a personal project and should not be used in real production environments. All documentation in this repo is for my own reference.

### Install of a new node
1. Run the [server-installer](./server-installer)
2. Install the [git-cloner](./git-cloner) cron job

When installing a new manager extra steps:
1. Install the [swarm-deployer](./swarm-deployer) cron job
