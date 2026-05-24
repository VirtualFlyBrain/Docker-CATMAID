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

# Upstream catmaid/catmaid-standalone bakes the PostgreSQL Global
# Development Group (PGDG) apt repo, but PGDG retired focal-pgdg when
# Ubuntu 20.04 hit standard EOL — its Release file is gone, so apt-get
# update aborts. Postgres is already installed in the base image, so we
# just disable the PGDG source before running update.
#
# focal is past standard support; we apply what patches still flow into
# focal-updates/focal-security with apt-get upgrade. ESM-only CVEs (e.g.
# many libssl, openssh, glibc fixes after April 2025) require an Ubuntu
# Pro token which we don't ship; the longer-term fix is to rebase
# catmaid-standalone on jammy or noble.
RUN rm -f /etc/apt/sources.list.d/pgdg.list /etc/apt/sources.list.d/postgresql.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && apt-get install -y r-base \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV INSTANCE_MEMORY=65000

ENTRYPOINT ["/opt/VFB/init.sh"]
