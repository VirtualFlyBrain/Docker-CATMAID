FROM catmaid/catmaid-standalone

ENV DB_USER=catmaid_user
ENV DB_PASS=catmaid_password
ENV PGPASSWORD=catmaid_password
ENV DB_NAME=catmaid
ENV CM_EXAMPLE_PROJECTS=false
ENV DB_CONF_FILE=/etc/postgresql/10/main/postgresql.conf
ENV CM_IMPORTED_SKELETON_FILE_MAXIMUM_SIZE=16777216
ENV CM_DEBUG=False
ENV CM_NODE_LIMIT=15000
ENV CM_NODE_PROVIDERS="[('cached_msgpack', { 'enabled': True, 'project_id': 1, 'min_width': 11100, 'min_heigth': 10000, 'orientation': 'xy', 'step': 35.0 }), 'postgis3d']"

VOLUME /backup

COPY modify_superuser.py /opt/VFB/modify_superuser.py

RUN mkdir -p /opt/VFB

COPY init.sh /opt/VFB/init.sh
COPY backup.sh /opt/VFB/backup.sh

RUN chmod -R 777 /opt/VFB

RUN chmod +x /opt/VFB/*.sh

RUN sed -i "s|#listen_addresses = 'localhost'|listen_addresses = '*'|g" $(find /etc/postgresql/ -name 'postgresql.conf')

RUN /bin/echo -e "\nlocal\tall\tpostgres\t\ttrust\nlocal\t${DB_NAME}\tall\t\ttrust\nhost\tall\tall\t0.0.0.0/0\ttrust\nhost\tall\tall\t0.0.0.0/0\tmd5\nhost\treplication\troot\t10.0.0.1/32\tmd5\n" > $(find /etc/postgresql/ -name 'pg_hba.conf')

RUN apt-get update && apt-get install -y r-base aria2

EXPOSE 5432

ENV INSTANCE_MEMORY=65000

ENTRYPOINT ["/opt/VFB/init.sh"]
