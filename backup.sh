#!/bin/bash
mkdir -p /backup/archive/
mv --backup=t /backup/catmaid_dum*.sql /backup/archive/
python /home/scripts/database/backup-database.py /backup/

