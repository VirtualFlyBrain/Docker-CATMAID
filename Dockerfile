FROM catmaid/catmaid-standalone

ENV DB_USER=catmaid_user
ENV DB_PASS=catmaid_password
ENV PGPASSWORD=catmaid_password
ENV DB_NAME=catmaid
ENV CM_EXAMPLE_PROJECTS=false
ENV CM_IMPORTED_SKELETON_FILE_MAXIMUM_SIZE=16777216
ENV CM_DEBUG=False
ENV DB_FIXTURE=true
ENV CM_NODE_LIMIT=15000
ENV CM_NODE_PROVIDERS="[('cached_msgpack', { 'enabled': True, 'project_id': 1, 'min_width': 11100, 'min_heigth': 10000, 'orientation': 'xy', 'step': 35.0 }), 'postgis3d']"

# VFB tracking: GA4 measurement ID injected into CATMAID's Django
# templates at container start by /opt/VFB/inject_gtm.py. Defaults to the
# live VFB property (G-K7DDZVVXM7) so all VFB-hosted CATMAID instances
# report into the same stream. Override per-instance, or set empty, to
# disable.
ENV GA_TAG_ID="G-K7DDZVVXM7"

VOLUME /backup

COPY modify_superuser.py /opt/VFB/modify_superuser.py

RUN mkdir -p /opt/VFB

COPY init.sh /opt/VFB/init.sh
COPY backup.sh /opt/VFB/backup.sh
COPY inject_gtm.py /opt/VFB/inject_gtm.py

RUN chmod -R 777 /opt/VFB

RUN chmod +x /opt/VFB/*.sh

RUN apt-get update && apt-get install -y r-base

ENV INSTANCE_MEMORY=65000

ENTRYPOINT ["/opt/VFB/init.sh"]
