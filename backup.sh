#!/bin/bash
mkdir -p /backup/archive/
mv --backup=t /backup/*.bz2 /backup/archive/
python /home/scripts/database/backup-database.py /backup/

