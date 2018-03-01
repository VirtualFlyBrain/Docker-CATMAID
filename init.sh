#!/bin/bash

# Start DB early 
service postgresql start

# Check for recovery DB
if [ $(ls /backup/*.bz2 | wc -l) -eq 1 ]; then
  python /home/scripts/database/revert-database.py /backup/*.bz2
fi

# start CATMAID
/home/scripts/docker/catmaid-entry.sh standalone
