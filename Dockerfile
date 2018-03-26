FROM catmaid/catmaid-standalone


ENV DB_USER=catmaid_user
ENV DB_PASS=catmaid_password
ENV PGPASSWORD=${DB_PASS}
ENV DB_NAME=catmaid
ENV CM_EXAMPLE_PROJECTS=false
ENV DB_CONF_FILE=$(find /etc/ -name 'pg_hba.conf')
VOLUME /backup

#swapping to bash 
RUN rm /bin/sh && ln -s /bin/bash /bin/sh && rm /bin/sh.distrib && ln -s /bin/bash /bin/sh.distrib

RUN apt-get -y -q update && apt-get -y -q install python-yaml python-psycopg2 

RUN echo -e "host: localhost\nport: 5432\ndatabase: catmaid\nusername: catmaid_user\npassword: catmaid_password" > ~/.catmaid-db

COPY catmaid_insert_project.py /home/django/applications/catmaid/management/commands/catmaid_insert_project.py

COPY modify_superuser.py /home/scripts/docker/modify_superuser.py

RUN sed -i '1s/^/local\tall\tall\t\ttrust\n/' $DB_CONF_FILE

RUN mkdir -p /opt/VFB

COPY init.sh /opt/VFB/init.sh
COPY backup.sh /opt/VFB/backup.sh

RUN chmod -R 777 /opt/VFB

RUN chmod +x /opt/VFB/*.sh

RUN /home/scripts/docker/catmaid-entry.sh standalone \
    & sleep 10m \
    && source /usr/share/virtualenvwrapper/virtualenvwrapper.sh \
    && workon catmaid \
    && cd /home/django/projects \
    && ls -l ./mysite/ \
    && cat /home/scripts/docker/modify_superuser.py | python manage.py shell

ENTRYPOINT ["/opt/VFB/init.sh"]
