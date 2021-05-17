# depth-api2


## clone project with submodules
```
git clone --recurse-submodules https://github.com/wldlzi/depth-api2.git
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

# install required python libraries
the following command install all required libraries
```
pip3 install --no-cache-dir -r requirements.txt
```

# initial setup of databases

## open shell in database docker container

assumtion: 
the user with 
 name="admin" 
 pass="admin" 
 and persmissions to create databases 
is configured in database.

enter following commands
```
# osmapi data (taken over from api2 project)
sudo -u postgres createdb -E UTF8 -O admin django-db -T template0

# for django
sudo -u postgres createdb -E UTF8 -O admin osmapi-db -T template0

# depth data (taken over from api2 project)
sudo -u postgres createdb -E UTF8 -O admin depth-db -T template0
```

# import database schema
```
sudo -u postgres psql -c "ALTER USER admin WITH SUPERUSER;"
sudo -u postgres psql -d osmapi-db -c "CREATE EXTENSION postgis;"
sudo -u postgres psql -h localhost -p 5432 -U admin -d osmapi-db -f /transfer/create_osmapi_db.sql
```


# Test
http://localhost:8003/static/local_index.html