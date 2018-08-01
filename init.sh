#!/bin/bash

# Start DB early 
service postgresql start

# start CATMAID
/home/scripts/docker/catmaid-entry.sh standalone &

echo 'Start of Service' >> /var/log/postgresql/postgresql-10-main.log
echo 'Start of Service' >> /var/log/nginx/error.log
echo 'Start of Service' >> /var/log/nginx/access.log

# Check for recovery DB
if [ $(ls /backup/*.bz2 | wc -l) -eq 1 ]; then
  sleep 1m
  python /home/scripts/database/revert-database.py /backup/*.bz2
  sleep 1m
  python /home/scripts/database/revert-database.py /backup/*.bz2
  # migrate DB
  source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
  workon catmaid
  cd /home/django/projects
  python manage.py catmaid_rebuild_edge_table
  python manage.py makemigrations catmaid
  python manage.py migrate
fi

tail -F /var/log/nginx/error.log >&2 &
tail -F /var/log/nginx/access.log &

tail -F /var/log/postgresql/postgresql-10-main.log
