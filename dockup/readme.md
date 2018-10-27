Backups all directories in `/backup` to AWS S3 on a cron interval. It compresses the directories (tar-gz), encrypts the directories (gpg AES256) before uploading with the hostname, directory name and timestamp as prefix.

Environment variables:
* `CRON` The cron pattern to run on. For example `0 30 * * * *` is every hour on the half hour.
* `BUCKET` The AWS S3 Bucket url without `s3://` prefix.
* `NAME` The name of of the backup.

Required fils/folders:
* `/backup` The directory that must contain all folders to be backed up. Should be mounted as read-only.
* `/etc/hosthostname` The file with the hostname of the docker host.
* `/run/secrets/passfile` The file where the encryption key is stored. **Encryption key must be 32 bytes.**
* `/run/secrets/aws-credentials` AWS credentials file that provides access to the bucket with profile 'default'. Example:

```toml
[default]
aws_access_key_id = <YOUR_ACCESS_KEY_ID>
aws_secret_access_key = <YOUR_SECRET_ACCESS_KEY>
```
