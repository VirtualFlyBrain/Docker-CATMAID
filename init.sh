#!/bin/bash

# Start DB early 
service postgresql start

# Check for recovery DB
if [ $(ls /backup/*.bz2 | wc -l) -eq 1 ]; then
  python /home/scripts/database/revert-database.py /backup/*.bz2
fi

echo 'START OF LOG' >> /var/log/nginx/error.log
# echo 'START OF LOG' >> /var/log/nginx/access.log
tail -F --retry /var/log/nginx/error.log &
# tail -F --retry /var/log/nginx/access.log &

# start CATMAID
/home/scripts/docker/catmaid-entry.sh standalone
