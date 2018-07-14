#!/usr/bin/env bash

TARFILE="/tmp.tar.gz"

# Compress it
# -z Compress archive using gzip program
# -c Create archive
# -v Verbose i.e display progress while creating archive
# -f Archive File name
tar czvf ${TARFILE} "/backup"

# Encrypt it
PASS=`cat ${PASSFILE}`
gpg --symmetric --cipher-algo AES256 --passphrase ${PASS} ${TARFILE}

# Send it to AWS
DATE=`date '+%Y-%m-%d %H:%M:%S'`
PREFIX=`cat ${HOSTHOSTFILE}`
export AWS_ACCESS_KEY_ID=`cat ${AWS_ACCESS_KEY_ID_FILE}`
export AWS_SECRET_ACCESS_KEY=`cat ${AWS_SECRET_ACCESS_KEY_FILE}`
export AWS_DEFAULT_REGION="$S3_REGION"

aws s3 cp ${TARFILE}.gpg "$S3_BUCKET/$PREFIX/$DATE.tar.gz.gpg"

rm ${TARFILE}
rm ${TARFILE}.gpg
