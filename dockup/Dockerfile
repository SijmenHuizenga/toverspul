FROM debian:jessie-slim

# Install AWS CLI
RUN apt-get update -y && apt-get install -y \
    awscli \
    s3cmd \
    cron \
  && rm -rf /var/lib/apt/lists/*

#Add crontab
ADD run.sh run.sh

ENTRYPOINT "./run.sh"