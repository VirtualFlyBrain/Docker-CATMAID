FROM catmaid/catmaid:stable

ENV TFTP-SERVER=vfbds0.inf.ed.ac.uk

COPY supervisor-catmaid.conf /etc/supervisor/conf.d/supervisor-catmaid.conf

RUN mkdir /opt/VFB

COPY nginx-catmaid.conf /etc/nginx/sites-enabled/

COPY init.sh /opt/VFB/init.sh 

RUN chmod -R 777 /opt/VFB

ENTRYPOINT ["/bin/bash", "-c", "/opt/VFB/init.sh"]
