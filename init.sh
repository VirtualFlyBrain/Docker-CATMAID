#!/bin/bash

# set DB password
echo -e "host: localhost\nport: 5432\ndatabase: ${DB_NAME}\nusername: ${DB_USER}\npassword: ${DB_PASS}" > ~/.catmaid-db

# set Debug
sed -i "s|DEBUG = *.|DEBUG = ${CM_DEBUG}|g" /home/django/projects/mysite/settings.py

# Start DB early 
service postgresql start

# start CATMAID
/home/scripts/docker/catmaid-entry.sh standalone &

echo 'Start of Service' >> /var/log/postgresql/postgresql-10-main.log
echo 'Start of Service' >> /var/log/nginx/error.log
echo 'Start of Service' >> /var/log/nginx/access.log

source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
workon catmaid
cd /home/django/projects

# Check for recovery DB
if [ $(ls /backup/*.bz2 | wc -l) -eq 1 ]; then
  sleep 1m
  python /home/scripts/database/revert-database.py /backup/*.bz2
  sleep 1m
  python /home/scripts/database/revert-database.py /backup/*.bz2
fi

# set Admin Password
cat /home/scripts/docker/modify_superuser.py | python manage.py shell

tail -F /var/log/nginx/error.log >&2 &
tail -F /var/log/nginx/access.log &

tail -F /var/log/postgresql/postgresql-10-main.log
