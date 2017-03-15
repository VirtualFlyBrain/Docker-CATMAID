FROM catmaid/catmaid:stable

COPY supervisor-catmaid.conf /etc/supervisor/conf.d/supervisor-catmaid.conf

RUN mkdir /opt/tiles

RUN mkdir /opt/VFB

COPY nginx-catmaid.conf /etc/nginx/sites-enabled/

COPY init.sh /opt/VFB/init.sh 

ENTRYPOINT ["/bin/bash", "-c", "/opt/VFB/init.sh"]
