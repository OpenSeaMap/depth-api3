# depth-api2


## clone repository
```
clone project with submodules
```


## configuration / settings
settings are stored in file ./depth3/.env

sample content:

```
DEBUG=True
SECRET_KEY='nvd@a^27y27t2c6=%9%pa9j73mhw-2*!b*z%4kt2gnu9!u(z7k'

# database used for django server
DB_ENGINE=django.db.backends.postgresql
DB_NAME=osmapi_2.5
DB_USER=admin
DB_PASSWORD=admin
DB_HOST=postgis
DB_PORT=5432

# database used from API2 backend (java / tomcat version)
DB_OSMAPI_ENGINE=django.db.backends.postgresql
DB_OSMAPI_NAME=osmapi
DB_OSMAPI_USER=admin
DB_OSMAPI_PASSWORD=admin
DB_OSMAPI_HOST=postgis
DB_OSMAPI_PORT=5432

# database used from API2 backend (java / tomcat version)
DB_DEPTH_ENGINE=django.db.backends.postgresql
DB_DEPTH_NAME=depth
DB_DEPTH_USER=admin
DB_DEPTH_PASSWORD=admin
DB_DEPTH_HOST=postgis
DB_DEPTH_PORT=5432

EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.openseamap.org'
EMAIL_PORT = '465'
EMAIL_HOST_USER = "admin@openseamap.org"
EMAIL_HOST_PASSWORD = "12345678"

UPLOAD_PATH=/data/uploads
```

# requirements
the following command install all required libraries
```
pip3 install --no-cache-dir -r requirements.txt
```

# Test
http://localhost:8003/static/local_index.html