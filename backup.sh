#!/bin/bash
mkdir -p /backup/archive/
mv --backup=t /backup/*.bz2 /backup/archive/
pg_dump --clean -U postgres --no-password catmaid | bzip2 > /backup/VFB-CATMAID-BACKUP_$(date +'%Y-%m-%dT%H_%M_%S')-C${HOSTNAME}.bz2
