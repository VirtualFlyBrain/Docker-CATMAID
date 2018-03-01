#!/bin/bash
mkdir -p /backup/archive/
mv --backup=t /backup/catmaid_dum*.sql /backup/archive/
pg_dump --clean -T treenode_edge -U catmaid_user catmaid -f /backup/catmaid_dump.sql

