FROM debian:jessie-slim

# Install AWS CLI
RUN apt-get update -y && apt-get install -y \
    awscli \
    s3cmd \
    cron \
  && rm -rf /var/lib/apt/lists/*

#Add crontab
ADD run.sh /run.sh
ADD backup.sh /backup.sh

ENV CRON "* * * * *"

ENV AWS_ACCESS_KEY_ID_FILE ""
ENV AWS_SECRET_ACCESS_KEY_FILE ""

ENV S3_REGION "region"
ENV S3_BUCKET "s3://test"

ENV HOSTHOSTFILE "/etc/hostname-host"
ENV PASSFILE "/etc/hostname-host"

ENTRYPOINT "/backup.sh"