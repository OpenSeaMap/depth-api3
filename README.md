# depth-api2

## setings
settings are stored in file ./depth3/.env

sample content:

```
DEBUG=True
SECRET_KEY='nvd@a^27y27t2c6=%9%pa9j73mhw-2*!b*z%4kt2gnu9!u(z7k'

DB_ENGINE='django.db.backends.postgresql'
DB_NAME='osmapi_2.5'
DB_USER='postgres'
DB_PASSWORD='postgres'
DB_HOST='127.0.0.1'
DB_PORT='5433'

EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.openseamap.org'
EMAIL_PORT = '465'
EMAIL_HOST_USER = "admin@openseamap.org"
EMAIL_HOST_PASSWORD = "12345678"
```

# requirements
```
pip3 install django-environ django-cors-headers django-simple-captcha
```

# Test
http://localhost:8003/static/local_index.html