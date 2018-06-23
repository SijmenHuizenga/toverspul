Force-updates a git repo to a directory.
  
  ```bash
  $ toverspul-swarm-deployer [repodir] [repourl]
  ```
  
  Clones the repo the repo or fetches updates and resets hard to origin/master
  
  ### Cron job installation
  ```bash
  wget https://raw.githubusercontent.com/SijmenHuizenga/toverspul/master/git-cloner/toverspul-git-cloner -O /usr/local/bin/toverspul-git-cloner
  chmod +x /usr/local/bin/toverspul-git-cloner
  crontab -l | { cat; echo "*/14 * * * * /usr/local/bin/toverspul-git-cloner /toverspul-config https://github.com/SijmenHuizenga/toverspul-config.git >> /var/log/toverspul-git-cloner.log 2>&1"; } | crontab -
  ```