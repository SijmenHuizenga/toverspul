Instructs certbot to request certificates based on a configuration file. Outputs the certificates in a pem format suited for HA-Proxy. Certbotbot checks every 5 minutes for updates. SSL certificates are only updated when they are about to expire or when the configured domains change. Domains that are removed from the configuration will not be deleted, just never updated.

`/certbotbot-config.yaml`

```yaml
httpport: 8888
email: example@example.com
googlecredentialsfilepath: /run/secrets/my_secret_data
cloudflarecredentialsfilepath: /run/secrets/my_other_secret_data
staging: true
dryrun: true
certs:
  - name: examplecom
    domain: example.com
    challenge: http
    subdomains:
      - a.example.com
      - b.example.com
  - name: testwildcard
    domain: "*.test.com"
    challenge: googledns
    subdomains: []

```

To use the challenge `googledns` it requires a google cloud platform service account key json file. 

To use the challenge `cloudflare` it requires a [cloudflare credentials file](https://certbot-dns-cloudflare.readthedocs.io/en/latest/).

To use the `route53` challenge it requires [aws credentials](https://certbot-dns-route53.readthedocs.io/en/latest/). These can be provided in the `~/.aws/config` (or other location as specified in the `AWS_CONFIG_FILE` env variable) or by providing the `AWS_ACCESS_KEY_ID` and `AWS_ACCESS_KEY_ID` environment variables.

The following things are stored in the following places and should be persistant:

* `/certbotbot/certs`       The output certificates
* `/certbotbot/le-config`   The configuration properties created by letsencrypt. 
* `/certbotbot/le-work`     The working directory for letsencrypt. 
* `/certbotbot/le-logs`     The logs file directory created by letsencrypt.
* `/etc/letsencrypt`        Storage for letsencrypt
* `/var/lib/letsencrypt`    More storage for letsencrypt

The output of every certificate is `/certbotbot/certs/{cert-name}.pem`

Certbotbot starts a webserver on port 80 that always returns OK. This is in place for health-checking the application.