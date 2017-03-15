FROM catmaid/catmaid:stable

# TFTP server with tiles
ENV FILESERVER=vfbds0.inf.ed.ac.uk

COPY supervisor-catmaid.conf /etc/supervisor/conf.d/supervisor-catmaid.conf

COPY catmaid_insert_L1EM_project.py /home/django/applications/catmaid/management/commands/catmaid_insert_L1EM_project.py

COPY create_superuser.py /home/scripts/docker/create_superuser.py

RUN mkdir /opt/VFB

COPY nginx-catmaid.conf /etc/nginx/sites-enabled/

COPY init.sh /opt/VFB/init.sh 

RUN chmod -R 777 /opt/VFB

RUN apt-get -y install tftp

ENTRYPOINT ["/bin/bash", "-c", "/opt/VFB/init.sh"]
