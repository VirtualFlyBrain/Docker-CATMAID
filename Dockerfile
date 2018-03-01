FROM catmaid/catmaid-standalone

ENV PGPASSWORD=catmaid_password
VOLUME /backup

#swapping to bash 
RUN rm /bin/sh && ln -s /bin/bash /bin/sh && rm /bin/sh.distrib && ln -s /bin/bash /bin/sh.distrib

RUN apt-get -y -q update && apt-get -y -q install python-yaml python-psycopg2 

RUN echo -e "host: localhost\nport: 5432\ndatabase: catmaid\nusername: catmaid_user\npassword: catmaid_password" > ~/.catmaid-db

COPY catmaid_insert_project.py /home/django/applications/catmaid/management/commands/catmaid_insert_project.py

COPY modify_superuser.py /home/scripts/docker/modify_superuser.py

RUN sed -i '1s/^/local\tall\tall\t\ttrust\n/' /etc/postgresql/9.6/main/pg_hba.conf

RUN mkdir -p /opt/VFB

COPY init.sh /opt/VFB/init.sh
COPY backup.sh /opt/VFB/backup.sh

RUN chmod -R 777 /opt/VFB

RUN chmod +x /opt/VFB/*.sh

ENTRYPOINT ["/opt/VFB/init.sh"]
