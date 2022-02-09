# depth-api2

## clone project with submodules
```
git clone --recurse-submodules git@github.com:OpenSeaMap/depth-api3.git
```

## configuration / settings
settings are not committed to SCM and needs to be stored in following file: 

```
 ./depth3/.env (if you run django on host)
 ./docker/.env (if you run django inside docker container)
```

you need to create the file with following sample content and adapt it to your needs:

```
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin

DEBUG=True
SECRET_KEY='nvd@a^27y27t2c6=%9%pa9j73mhw-2*!b*z%4kt2gnu9!u(z7k'

# database used for django server
DB_ENGINE=django.db.backends.postgresql
DB_NAME=osmapi-db
DB_USER=admin
DB_PASSWORD=admin
DB_HOST=postgis
DB_PORT=5432

# database used from API2 backend (java / tomcat version)
DB_OSMAPI_ENGINE=django.db.backends.postgresql
DB_OSMAPI_NAME=osmapi-db
DB_OSMAPI_USER=admin
DB_OSMAPI_PASSWORD=admin
DB_OSMAPI_HOST=postgis
DB_OSMAPI_PORT=5432

# database used from API2 backend (java / tomcat version)
DB_DEPTH_ENGINE=django.db.backends.postgresql
DB_DEPTH_NAME=depth-db
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
LOGFILENAME=/data/log/osmapi.log

```

# start docker based solution

## start docker container

```
docker-compose up -d
```

## stop docker container

```
docker-compose down 
```

## initial setup of databases

### open shell in database docker container

assumtion: 
the user with name="admin" and pass="admin" and persmissions to create databases is configured in database.

enter following commands

```
# osmapi data (taken over from api2 project)
sudo -u postgres createdb -E UTF8 -O admin django-db -T template0

# for django
sudo -u postgres createdb -E UTF8 -O admin osmapi-db -T template0

# depth data (taken over from api2 project)
sudo -u postgres createdb -E UTF8 -O admin depth-db -T template0

# import database schema
sudo -u postgres psql -c "ALTER USER admin WITH SUPERUSER;"
sudo -u postgres psql -d osmapi-db -c "CREATE EXTENSION postgis;"
sudo -u postgres psql -h localhost -p 5432 -U admin -d osmapi-db -f /transfer/create_osmapi_db.sql
```

## initial setup of django

open a shell in osmapi docker container

```
docker-compose exec osmapi /bin/bash
```

enter following commands

```
/run.sh migrate
```


# start django web application without docker

## install required python libraries
the following command installs all required libraries

```
pip3 install --no-cache-dir -r requirements.txt
```

## start django

```
cd depth-api3
python3 manage.py runserver 0.0.0.0:4040
```

the server shows following output if startup was successfull:

```
Performing system checks...
System check identified no issues (1 silenced).
February 09, 2022 - 15:35:59
Django version 3.2, using settings 'depth3.settings'
Starting development server at http://0.0.0.0:4040/
Quit the server with CONTROL-C.
```


# Test
http://localhost:4040/