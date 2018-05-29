FROM catmaid/catmaid:stable

#swapping to bash 
RUN rm /bin/sh && ln -s /bin/bash /bin/sh && rm /bin/sh.distrib && ln -s /bin/bash /bin/sh.distrib

COPY supervisor-catmaid.conf /etc/supervisor/conf.d/supervisor-catmaid.conf

COPY catmaid_insert_L1EM_project.py /home/django/applications/catmaid/management/commands/catmaid_insert_L1EM_project.py

COPY modify_superuser.py /home/scripts/docker/modify_superuser.py

RUN mkdir /opt/VFB

COPY nginx-catmaid.conf /etc/nginx/sites-enabled/

COPY init.sh /opt/VFB/init.sh 

RUN chmod -R 777 /opt/VFB

RUN sed -i "s|#listen_addresses = 'localhost'|listen_addresses = '*'" /etc/postgresql/10/main/postgresql.conf

EXPOSE 5432

RUN service postgresql start \
    && sleep 10m \
    && source /usr/share/virtualenvwrapper/virtualenvwrapper.sh \
    && workon catmaid \
    && cd /home/django/projects \
    && cat /home/scripts/docker/modify_superuser.py | python manage.py shell \
    && python manage.py catmaid_insert_L1EM_project --user=1

ENTRYPOINT ["/bin/bash", "-c", "/opt/VFB/init.sh"]
