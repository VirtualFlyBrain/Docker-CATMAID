#!/bin/bash

# Start DB early 
service postgresql start

# Load tile data
ln -s /opt/VFB/L1EM /opt/tiles
cd /opt/VFB/ 
echo 'get /catmaid/L1EM.tar.gz' | tftp ${TFTP-SERVER} && tar -zxvf L1EM.tar.gz &

# start CATMAID
supervisord -n
