#!/bin/bash

# Start DB early 
service postgresql start



# Check for recovery DB
if [ $(ls /backup/*.bz2 | wc -l) -eq 1 ]; then
  sleep 1m
  source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
  workon catmaid
  cd /home/django/projects
  python /home/scripts/database/revert-database.py /backup/*.bz2
  sleep 1m
fi

echo 'START OF LOG' >> /var/log/nginx/error.log
# echo 'START OF LOG' >> /var/log/nginx/access.log
tail -F --retry /var/log/nginx/error.log &
# tail -F --retry /var/log/nginx/access.log &

# start CATMAID
/home/scripts/docker/catmaid-entry.sh standalone &

# migrate DB
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
workon catmaid
cd /home/django/projects
python manage.py makemigrations catmaid
python manage.py migrate

echo 'Start of Service' >> /var/log/postgresql/postgresql-10-main.log
echo 'Start of Service' >> /var/log/nginx/error.log
echo 'Start of Service' >> /var/log/nginx/access.log


tail -F /var/log/nginx/error.log >&2 &
tail -F /var/log/nginx/access.log &

tail -F /var/log/postgresql/postgresql-10-main.log
