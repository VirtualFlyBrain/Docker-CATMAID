#!/bin/bash

echo 'Start of Service' >> /var/log/postgresql/postgresql-11-main.log
echo 'Start of Service' >> /var/log/nginx/error.log
echo 'Start of Service' >> /var/log/nginx/access.log

# set Admin Password
sleep 2m && \
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh && \
workon catmaid && \
cd /home/django/projectscat /opt/VFB/modify_superuser.py | python manage.py shell &

tail -F /var/log/nginx/error.log >&2 &
tail -F /var/log/nginx/access.log &
tail -F /var/log/postgresql/postgresql-11-main.log &

if [ -e /backup/*.pgsql ]
then
  export DB_FIXTURE=true
  cat /backup/*.pgsql | /home/scripts/docker/catmaid-entry.sh standalone
else
  /bin/bash /home/scripts/docker/catmaid-entry.sh standalone
fi
