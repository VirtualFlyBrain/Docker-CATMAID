#!/bin/bash

# set DB password
/bin/echo -e "host: localhost\nport: 5432\ndatabase: ${DB_NAME}\nusername: ${DB_USER}\npassword: ${DB_PASS}" > ~/.catmaid-db

# initiate catmaid setup
/bin/bash /home/scripts/docker/catmaid-entry.sh init_catmaid &

# Start DB
service postgresql start

source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
workon catmaid
cd /home/django/projects

# Check for recovery DB
if [ $(ls /backup/*.bz2 | wc -l) -eq 1 ]; then
  sleep 20s
  psql -U postgres --no-password -c "CREATE USER ${DB_USER} WITH CREATEDB CREATEROLE SUPERUSER PASSWORD '${DB_PASS}';"
  bunzip2 -c /backup/*.bz2 | pg_restore --create --clean -U postgres --no-password -d postgres
fi

# start CATMAID
/bin/bash /home/scripts/docker/catmaid-entry.sh standalone &

echo 'Start of Service' >> /var/log/postgresql/postgresql-10-main.log
echo 'Start of Service' >> /var/log/nginx/error.log
echo 'Start of Service' >> /var/log/nginx/access.log

# set Admin Password
cat /opt/VFB/modify_superuser.py | python manage.py shell

# set Debug
sed -i "s|DEBUG = .*|DEBUG = ${CM_DEBUG}|g" /home/django/projects/mysite/settings.py

# setup cache
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
workon catmaid
cd /home/django/projects
manage.py catmaid_update_cache_tables --from-config

tail -F /var/log/nginx/error.log >&2 &
tail -F /var/log/nginx/access.log &

tail -F /var/log/postgresql/postgresql-10-main.log
