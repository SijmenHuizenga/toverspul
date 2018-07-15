FROM debian:jessie-slim

# Install AWS CLI
RUN apt-get update -y && apt-get install -y cron wget python && rm -rf /var/lib/apt/lists/*

RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py

RUN pip install awscli

ENV CRON "* * * * *"

ENV AWS_ACCESS_KEY_ID_FILE ""
ENV AWS_SECRET_ACCESS_KEY_FILE ""

ENV S3_REGION "eu-central-1"
ENV S3_BUCKET ""

ENV HOSTHOSTFILE "/etc/hostname-host"
ENV PASSFILE "/run/secrets/passfile"

ADD run.sh /run.sh
ADD backup.sh /backup.sh

ENTRYPOINT "/run.sh"