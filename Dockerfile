FROM catmaid/catmaid-standalone


ENV DB_USER=catmaid_user
ENV DB_PASS=catmaid_password
ENV PGPASSWORD=${DB_PASS}
ENV DB_NAME=catmaid
ENV CM_EXAMPLE_PROJECTS=false
ENV DB_CONF_FILE=/etc/postgresql/10/main/postgresql.conf
ENV CM_IMPORTED_SKELETON_FILE_MAXIMUM_SIZE=16777216

VOLUME /backup

RUN echo -e "host: localhost\nport: 5432\ndatabase: catmaid\nusername: catmaid_user\npassword: catmaid_password" > ~/.catmaid-db

RUN sed -i "s|server {|server {\n    client_max_body_size    20M;\n    proxy_connect_timeout   600;\n    proxy_send_timeout      600;\n    proxy_read_timeout      600;\n    send_timeout            600;|g" /home/scripts/docker/nginx-catmaid.conf

COPY modify_superuser.py /home/scripts/docker/modify_superuser.py

RUN echo "$(find /etc/ -name 'pg_hba.conf')" && sed -i '1s/^/local\tall\tall\t\ttrust\n/' $(find /etc/ -name 'pg_hba.conf')

RUN mkdir -p /opt/VFB

COPY init.sh /opt/VFB/init.sh
COPY backup.sh /opt/VFB/backup.sh

RUN chmod -R 777 /opt/VFB

RUN chmod +x /opt/VFB/*.sh

RUN sed -i "s|#listen_addresses = 'localhost'|listen_addresses = '*'|g" /etc/postgresql/10/main/postgresql.conf

RUN echo -e "\nhost  all  all 0.0.0.0/0 md5\n" >> /etc/postgresql/10/main/pg_hba.conf

RUN sed -i "s|DEBUG = *.|DEBUG = ${CM_DEBUG}|g" /home/django/projects/mysite/settings.py

EXPOSE 5432

ENV INSTANCE_MEMORY=65000

ENTRYPOINT ["/opt/VFB/init.sh"]
