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

# Force the admin password to match CM_INITIAL_ADMIN_PASS.
#
# Upstream create_superuser.py only creates a superuser when none exists, so on
# an instance restored from a /backup dump it does nothing and the environment
# variable is silently ignored - the admin password stays whatever the dump
# carried. Postgres data lives inside the container, so a manual fix is lost on
# the next recreate; this reapplies it on every boot.
#
# catmaid-entry.sh below never returns, so wait for the database in the
# background. modify_superuser.py is idempotent and a no-op when the password
# already matches or CM_INITIAL_ADMIN_PASS is unset.
(
  cd /home/django/projects || exit 0
  for _ in $(seq 1 120); do
    if printf '\n\n' | cat /opt/VFB/modify_superuser.py - \
         | /home/env/bin/python manage.py shell 2>/dev/null \
         | grep '^modify_superuser:'; then
      exit 0
    fi
    sleep 5
  done
  echo "modify_superuser: database not ready after 10 minutes, giving up" >&2
) &

if [ -e /backup/*.pgsql ]
then
  export DB_FIXTURE=true
  cat /backup/*.pgsql | /home/scripts/docker/catmaid-entry.sh standalone
else
  /bin/bash /home/scripts/docker/catmaid-entry.sh standalone
fi
