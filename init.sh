#!/bin/bash

# Start DB early 
service postgresql start

# start CATMAID
supervisord -n
