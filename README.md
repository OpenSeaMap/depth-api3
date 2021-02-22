# depth-api3 -- backend REST API for track, vessel and user data
This implements a REST API giving CRUD operations on track, vessel and user data. it also implements a number of tiled views of the uploaded track points --
contours, specifically.

The code also manages the database operations, including database migrations thanks to Django. Only postgresql with POSTGIS extensions is supported.

Finally, the code includes functionality to import tracks into the database, and to do hierarchical simplification of the data points, to support near
real-time rendering of the tiled views.

## Installation
Probably the easiest way to install depth-api3 is to use docker and docker-compose. To install, do the following:

### clone repository
use following command to clone the repository with submodules
```
git clone --recurse-submodules https://github.com/OpenSeaMap/depth-api3.git
cd depth-api3

```

### server environment configuration
In the project main directory (i.e. alongside the dockercompose.yml), create a file .env that contains the following:

```INI
# set these
POSTGRES_USER=postgres
POSTGRES_PASSWORD=databaseadminpassword

# set this to the FQDN of the host your server runs on
SERVER_HOST=mybackend.server.org

# the admin of django
SUPERUSER=admin
SUPERUSER_PASSWORD=admin_password
SUPERUSER_EMAIL=django@someone.here
```

## Initial setup
The repository supports docker and docker-compose for fast and reproducable setup of
developmend and test server.

Show [1] and [2] for installation details of docker.  

### clone repository
```
git@github.com:OpenSeaMap/depth-api3.git
```

### docker - build images
```
cd depth-api3
docker-compose build
```

### create network
There is a internal network required for secure communication of docker container
following command creates that network and assigm the name docker_dmz.
```
docker network create docker_dmz
```

### start docker container
The required docker container can be started with following command:
```
docker-compose up -d
```

## usefull docker commands

```
# show logfiles
docker-compose logs

#stop and remove docker container
docker-compose stop
docker-compose kill
docker-compose rm

# remove relevant docker volumes
docker volume rm osm-depth-api3_TRACKS_DATA
docker volume rm osm-depth-api3_POSTGIS_DATA
```

### Testing
Open webbrowser on your development machine and check following URL's

```
 api root:
  http://localhost:8000/

 login sample:
  http://localhost:8000/http://192.168.1.54:8001/api-auth/login/

 download get tile (z=16,x=200, y=300):
  http://192.168.1.54:8001/1.0/tiles/contour/16/200/300
```

...
## Source code structure
...

# BOOKMARKS
 [1] setup docker https://docs.docker.com/engine/install/debian/ <br>
 [2] setup docker compose https://docs.docker.com/engine/install/debian/
