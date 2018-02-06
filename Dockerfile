FROM catmaid/catmaid-standalone

#swapping to bash 
RUN rm /bin/sh && ln -s /bin/bash /bin/sh && rm /bin/sh.distrib && ln -s /bin/bash /bin/sh.distrib

COPY catmaid_insert_project.py /home/django/applications/catmaid/management/commands/catmaid_insert_project.py

COPY modify_superuser.py /home/scripts/docker/modify_superuser.py

RUN mkdir -p /opt/VFB

COPY init.sh /opt/VFB/init.sh

RUN chmod -R 777 /opt/VFB

RUN chmod +x /opt/VFB/init.sh

RUN /home/scripts/docker/catmaid-entry.sh standalone \
    & sleep 10m \
    && source /usr/share/virtualenvwrapper/virtualenvwrapper.sh \
    && workon catmaid \
    && cd /home/django/projects \
    && ls -l ./mysite/ \
    && cat /home/scripts/docker/modify_superuser.py | python manage.py shell \
    && python manage.py catmaid_insert_project --user=1

ENTRYPOINT ["/opt/VFB/init.sh"]
