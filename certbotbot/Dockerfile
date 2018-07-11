FROM certbot/dns-google

ADD toverspul-certbotbot /usr/local/bin/toverspul-certbotbot

ENV CONFIGFILE "/config.yml"

ENTRYPOINT ["/usr/local/bin/toverspul-certbotbot"]