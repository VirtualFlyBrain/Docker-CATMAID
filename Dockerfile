FROM catmaid/catmaid:stable

# Ensuring all installed 
RUN apt-get -y install nginx uwsgi uwsgi-plugin-python
