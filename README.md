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

# create initial database database
## django sb

# generate databases

## general 
```
# osmapi data (taken over from api2 project)
sudo -u postgres createdb -E UTF8 -O admin osmapi -T template0

# for django
sudo -u postgres createdb -E UTF8 -O admin osmapi_2.5 -T template0

# depth data (taken over from api2 project)
sudo -u postgres createdb -E UTF8 -O admin depth -T template0
```

## import database schema for osmapi
```
sudo -u postgres psql -d osmapi -c "CREATE EXTENSION postgis;"
sudo -u postgres psql -h localhost -p 5432 -U admin -d osmapi -f /transfer/create_schema.sql
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.depthsensor TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.gauge TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.gaugemeasurement TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.license TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.rpl_journal TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.sbassensor TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.spatial_ref_sys TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.track_info TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.trackgauges TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.user_profiles TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.user_tracks TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.userroles TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.vesselconfiguration TO admin;"

sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.depthsensor_id_seq OWNER TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.gauge_id_seq OWNER TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.license_id_seq OWNER TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.repl_id_seq OWNER TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.sbassensor_id_seq OWNER TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.trackgauges_id_seq OWNER TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.user_profiles_id_seq OWNER TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.user_tracks_track_id_seq OWNER TO admin;"
sudo -u postgres psql -d osmapi -c "GRANT ALL ON TABLE public.vesselconfiguration_id_seq OWNER TO admin;"


```



# Test
http://localhost:8003/static/local_index.html