#!/bin/bash
source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
workon catmaid
cd /home/django/projects
mkdir -p /backup/archive/
mv --backup=t /backup/*.bz2 /backup/archive/
python /home/scripts/database/backup-database.py /backup/

