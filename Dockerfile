FROM catmaid/catmaid:stable

# TFTP server with tiles
ENV FILESERVER=vfbds0.inf.ed.ac.uk

#swapping to bash 
RUN rm /bin/sh && ln -s /bin/bash /bin/sh && rm /bin/sh.distrib && ln -s /bin/bash /bin/sh.distrib

COPY supervisor-catmaid.conf /etc/supervisor/conf.d/supervisor-catmaid.conf

COPY catmaid_insert_L1EM_project.py /home/django/applications/catmaid/management/commands/catmaid_insert_L1EM_project.py

COPY modify_superuser.py /home/scripts/docker/modify_superuser.py

RUN mkdir /opt/VFB

COPY nginx-catmaid.conf /etc/nginx/sites-enabled/

COPY init.sh /opt/VFB/init.sh 

COPY tftpbatch.sh /opt/VFB/tftpbatch.sh 

RUN chmod -R 777 /opt/VFB

RUN apt-get -y install tftp curl

RUN service postgresql start \
    && sleep 10m \
    && source /usr/share/virtualenvwrapper/virtualenvwrapper.sh \
    && workon catmaid \
    && cd /home/django/projects/mysite \
    && cat /home/scripts/docker/modify_superuser.py | python manage.py shell \
    && python manage.py catmaid_insert_L1EM_project --user=1

VOLUME /opt/VFB/L1EM

ENTRYPOINT ["/bin/bash", "-c", "/opt/VFB/init.sh"]
