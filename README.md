# depth-api3 -- backend REST API for track, vessel and user data
This implements a REST API giving CRUD operations on track, vessel and user data. it also implements a number of tiled views of the uploaded track points --
contours, specifically.

The code also manages the database operations, including database migrations thanks to Django. Only postgresql with POSTGIS extensions is supported.

Finally, the code includes functionality to import tracks into the database, and to do hierarchical simplification of the data points, to support near
real-time rendering of the tiled views.

## Installation
Probably the easiest way to install depth-api3 is to use docker and docker-compose. To install, do the following:
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
### Initial setup
...
### Testing
...
## Source code structure
...
