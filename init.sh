#!/bin/bash

# Start DB early 
service postgresql start

# Load tile data
ln -s /opt/VFB/L1EM /opt/tiles
cd /opt/VFB/ 
tftp $TFTP-SERVER << fin
  get /catmaid/L1EM.tar.gz 
  quit
fin && \
tar -zxvf L1EM.tar.gz &

# start CATMAID
supervisord -n
