#!/bin/bash

# Start DB early 
service postgresql start

# Check for recovery DB
if [ $(ls /backup/catmaid_dum*.sql | wc -l) -eq 1 ]; then
  psql -U catmaid_user -d catmaid -f /backup/catmaid_dum*.sql
fi

# start CATMAID
/home/scripts/docker/catmaid-entry.sh standalone
