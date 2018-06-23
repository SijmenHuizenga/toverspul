all: make-git-cloner make-server-installer make-swarm-deployer

make-git-cloner:
	cd git-cloner && make

make-server-installer:
	cd server-installer && make

make-swarm-deployer:
	cd swarm-deployer && make