#!/bin/bash

# Start DB early 
service postgresql start

# Load tile data
ln -s /opt/VFB/L1EM /opt/tiles
cd /opt/VFB/ 
echo 'get /catmaid/files.txt' | tftp "${FILESERVER}" && /opt/VFB/tftpbatch.sh /opt/VFB/files.txt "${FILESERVER}" &

# start CATMAID
supervisord -n
