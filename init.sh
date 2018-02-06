#!/bin/bash

# Start DB early 
service postgresql start

# start CATMAID
/home/scripts/docker/catmaid-entry.sh standalone
