#!/usr/bin/env bash

echo "* * * * * aws > /proc/\$(cat /var/run/crond.pid)/fd/1 2>&1" > crontab.conf

crontab ./crontab.conf

echo "Enabeling daily backups"
cron -f -L 15