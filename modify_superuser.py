from django.contrib.auth.models import User
user = User.objects.get(username='admin')
user.password=u'pbkdf2_sha256$24000$OlTY7BRHr07a$Pw2rmvcwaFAx0o/ogfagwptO9/R4PtmoA407MNFYUSU='
