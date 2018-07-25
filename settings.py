from __future__ import absolute_import
# If you don't have settings.py in this directory, you should copy
# this file to settings.py and customize it.

from mysite.settings_base import *
import hashlib

DATABASES = {
    'default': {
        'ENGINE': 'custom_postgresql_psycopg2', # Add 'postgresql_psycopg2', 'postgresql', 'mysql', 'sqlite3' or 'oracle'.
        'ATOMIC_REQUESTS': True,              # Wrap every request in a transaction
        'NAME': 'catmaid',      # Or path to database file if using sqlite3.
        'USER': 'catmaid_user',  # Not used with sqlite3.
        'PASSWORD': 'catmaid_password',  # Not used with sqlite3.
        'HOST': 'localhost',      # Set to empty string for localhost. Not used with sqlite3.
        'PORT': '5432',      # Set to empty string for default. Not used with sqlite3.
    }
}

DEBUG = False

# Make this unique, and don't share it with anybody.
# (You can generate a key with:
# >>> from random import choice
# >>> ''.join([choice('abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*(-_=+)') for i in range(50)])
# '@er^vm3$w#9n$)z3avny*hh+l^#ezv+sx*(72qwp0c%%cg1$i+'
# ... which is how "django-admin startproject" does it.)
SECRET_KEY = 'qg4*j)wxi#yg3nwd7el!n#&)o^w-tjqm52$l&j0_qgihr&$1pc'

# Absolute path to the directory that holds user generated data
# like cropped microstacks. Make sure this folder is writable by
# the user running the webserver (and Celery if croppish should
# be used).
# Example: "/var/www/example.org/media/"
MEDIA_ROOT = ''

# URL that gives access to files stored in MEDIA_ROOT (managed stored
# files). It must end in a slash if set to a non-empty value.
# Example: "http://media.example.org/"
MEDIA_URL = '/files/'

# The URL where static files can be accessed, relative to the domain's root
STATIC_URL = '/static/'
# The absolute local path where the static files get collected to
STATIC_ROOT =  '/home/django/static'

# Local time zone for this installation. Choices can be found here:
# http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
# although not all choices may be available on all operating systems.
# If running in a Windows environment this must be set to the same as your
# system time zone.
TIME_ZONE = 'UTC'

# This is used as a security measure by Django by validating a request's Host
# header. This setting is required when DEBUG is False. A dot ('.') in front of
# the host name indicates that also subdomains are allowed.
ALLOWED_HOSTS = ['*']

# Usually, CATMAID's Django back-end is not accessible on a domain's
# root ('/'), but rather a sub-directory like 'catmaid'. Django needs
# to know about this relative path and some web and WSGI servers pass
# this information to Django automatically (e.g. Apache + mod_wsgi).
# However, some don't (e.g. Nginx + Gevent) and the easiest way to
# tell Django were it lives is with the help of the FORCE_SCRIPT_NAME
# variable. It must not have a trailing slash. Therefore, if CATMAID
# runs in the root of a domain, this setting needs to be commented out.
# FORCE_SCRIPT_NAME = '/'

# URL of your CATMAID's Django instance, relative to the domain root
CATMAID_URL = '/'

# Use different cookie names for each CATMAID instance. This increases the size
# of the cookie. So if you run only one instance on this domain, you could also
# remove the next three lines.
COOKIE_SUFFIX = hashlib.md5(CATMAID_URL.encode('utf-8')).hexdigest()
SESSION_COOKIE_NAME = 'sessionid_' + COOKIE_SUFFIX
CSRF_COOKIE_NAME = 'csrftoken_' + COOKIE_SUFFIX

# Local path to store HDF5 files
# File name convention: {projectid}_{stackid}.hdf
HDF5_STORAGE_PATH = '/home/django/hdf5/'

# Importer settings
# If you want to use the importer, please adjust these settings. The
# CATMAID_IMPORT_PATH in (and below) the importer should look for new
# data. The IMPORTER_DEFAULT_IMAGE_BASE refers is the URL as seen from
# outside that gives read access to the CATMAID_IMPORT_PATH. It is used if
# imported stacks don't provide their URL explicitly.
CATMAID_IMPORT_PATH = '/home/httpdocs/data'
IMPORTER_DEFAULT_IMAGE_BASE = 'http://*/data'

# The URL under which custom front-end code can be made available
STATIC_EXTENSION_URL = '/staticext/'
# The absolute local path where the static extension files live
STATIC_EXTENSION_ROOT =  '/home/django/staticext'

# Gives Django access to installed CATMAID extensions - do not change without good reason.
# See https://catmaid.readthedocs.io/en/stable/extensions.html for more details
INSTALLED_APPS += tuple('{}.apps.{}Config'.format(app_name, app_name.title()) for app_name in INSTALLED_EXTENSIONS)
