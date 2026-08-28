# -*- coding: utf-8 -*-
# Force CATMAID's admin account to the password given in the environment.
#
# Upstream scripts/docker/create_superuser.py only acts when NO superuser
# exists:
#
#     if User.objects.filter(is_superuser=True).count() == 0:
#         User.objects.create_superuser(...)
#
# Every VFB instance boots by restoring a *.pgsql dump that already contains
# superusers, so that check always fails and CM_INITIAL_ADMIN_PASS is silently
# ignored. The admin password is then whatever the dump happened to carry,
# which drifts per instance and cannot be corrected durably by setting the
# environment variable.
#
# This script closes that gap. It is idempotent: it only writes when the
# password (or the staff/active flags) actually differ, so a boot that is
# already correct touches nothing.
#
# Piped into `manage.py shell` by init.sh; the file needs a trailing blank
# line so the input stream ends cleanly.
import os

from django.contrib.auth.models import User

admin_user = os.environ.get('CM_INITIAL_ADMIN_USER', 'admin')
admin_pass = os.environ.get('CM_INITIAL_ADMIN_PASS')

if not admin_pass:
    print('modify_superuser: CM_INITIAL_ADMIN_PASS is not set, leaving the password unchanged')
else:
    user = User.objects.filter(username=admin_user).first()
    if user is None:
        print('modify_superuser: no user %r on this instance, nothing to do' % admin_user)
    elif user.check_password(admin_pass) and user.is_staff and user.is_active:
        print('modify_superuser: %r already matches the environment, no change' % admin_user)
    else:
        user.set_password(admin_pass)
        user.is_staff = True
        user.is_active = True
        user.save()
        print('modify_superuser: reset the password for %r from the environment' % admin_user)
