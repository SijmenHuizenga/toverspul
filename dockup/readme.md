Backups the `/backup` diretory to AWS S3 on a cron interval. It compresses the directory (tar-gz), encrypts the directory (gpg AES256) before uploading with the host hostname and timestamp as prefix.

* `CRON` The cron pattern to run on. Default `* * * * *`.
* `AWS_ACCESS_KEY_ID_FILE` The file where the aws access key id is stored. 
* `AWS_SECRET_ACCESS_KEY_FILE` The file where the aws secret access key is stored.
* `S3_REGION` The AWS Region. Default `eu-central-1`
* `S3_BUCKET` The AWS S3 Bucket url. For example `s3://test`
* `HOSTHOSTFILE` The file where the hostname of the docker host is stored. This value is used as prefix. Default `/etc/hostname-host`
* `PASSFILE` The file where the encryption key is stored. Default `/run/secrets/passfile`

To decrypt a backup file:

`gpg --output backup.tar.gz -d backup.tar.gz.gpg`