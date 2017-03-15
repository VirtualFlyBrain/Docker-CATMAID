FROM catmaid/catmaid:stable

# TFTP server with tiles
ENV FILESERVER=vfbds0.inf.ed.ac.uk

COPY supervisor-catmaid.conf /etc/supervisor/conf.d/supervisor-catmaid.conf

COPY catmaid_insert_L1EM_project.py /home/django/applications/catmaid/management/commands/catmaid_insert_L1EM_project.py

COPY modify_superuser.py /home/scripts/docker/modify_superuser.py

RUN mkdir /opt/VFB

COPY nginx-catmaid.conf /etc/nginx/sites-enabled/

COPY init.sh /opt/VFB/init.sh 

RUN chmod -R 777 /opt/VFB

RUN apt-get -y install tftp

RUN service postgresql start \
    && /bin/bash -c "source /usr/share/virtualenvwrapper/virtualenvwrapper.sh \
    && workon catmaid \
    && cd /home/django/projects/mysite \
    && python manage.py migrate --noinput \
    && python manage.py collectstatic --clear --link --noinput \
    && cat /home/scripts/docker/modify_superuser.py | python manage.py shell \
    && python manage.py catmaid_insert_L1EM_project --user=1"

ENTRYPOINT ["/bin/bash", "-c", "/opt/VFB/init.sh"]
