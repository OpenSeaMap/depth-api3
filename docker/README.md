
# generate docker container
create-osm-images.sh  


# start docker container
docker-compose up -d

# stop docker container
docker-compose down

# initial setup of databases

## open shell in database docker container
```
docker-compose exec postgis /bin/bash
```

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
