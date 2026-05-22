#!/bin/bash

echo 'Start of Service' >> /var/log/postgresql/postgresql-11-main.log
echo 'Start of Service' >> /var/log/nginx/error.log
echo 'Start of Service' >> /var/log/nginx/access.log

tail -F /var/log/nginx/error.log >&2 &
tail -F /var/log/nginx/access.log &
tail -F /var/log/postgresql/postgresql-11-main.log &

# Inject the VFB GA4 gtag.js snippet into CATMAID templates if GA_TAG_ID
# is set. No-op when empty. Idempotent across container restarts.
python3 /opt/VFB/inject_gtm.py || echo "inject_ga: non-fatal failure, continuing"

if [ -e /backup/*.pgsql ]
then
  export DB_FIXTURE=true
  cat /backup/*.pgsql | /home/scripts/docker/catmaid-entry.sh standalone
else
  /bin/bash /home/scripts/docker/catmaid-entry.sh standalone
fi
