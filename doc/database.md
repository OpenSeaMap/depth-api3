# notes from 12.02.20201


# restore database  osmapi + depth
postgresql		V11.9
postgis			V2.5.1
pgadmin			V4.30


## install postgress + postgus on debian 10
```
sudo apt-get install postgresql-11 postgresql-client-11
sudo -u postgres createuser osm
sudo -u postgres createdb --encoding=UTF8 --owner=osm osmapi
sudo -u postgres createdb --encoding=UTF8 --owner=osm depth
sudo apt-get install postgis
```

## create dump
```
pg_dump -p 5435 -U postgres -Fc -b -v -f "./20210212_osmapi.dump" osmapi
```

CREATE EXTENSION IF NOT EXISTS plpgsql;
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster; -- OPTIONAL
CREATE EXTENSION postgis_topology; -- OPTIONAL


## create and restore db
```
createuser osm
createdb -U postgres --encoding=UTF8 --owner=osm osmapi
createdb -U postgres --encoding=UTF8 --owner=osm depth

pg_restore -d osmapi -U postgres -C /transfer/20210212_osmapi.dump
```



## open question

stevo: I think we need to enable POSTGIS extension with command
```
CREATE EXTENSION postgis;
```
