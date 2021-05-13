#!/bin/bash

# set -x

STOP_CONT="no"

# handler for term signal
function sighandler_TERM() {
    echo "signal SIGTERM received\n"
    service postgresql stop
    STOP_CONT="yes"
}

function createPostgresConfig() {
  cp /etc/postgresql/9.6/main/postgresql.custom.conf.tmpl /etc/postgresql/9.6/main/postgresql.custom.conf
  cat /etc/postgresql/9.6/main/postgresql.custom.conf
}


function initDb() {
  chown -R postgres:postgres /var/lib/postgresql
  sudo -u postgres /usr/lib/postgresql/9.6/bin/initdb -D /var/lib/postgresql/data
}

function setPostgresPassword {
  if [ -z "${POSTGRES_USER}" ]; then
    $POSTGRES_USER=admin
  fi

  if [ -z "${POSTGRES_PASSWORD}" ]; then
    $POSTGRES_PASSWORD=qwertz
  fi

  if sudo -u postgres psql -t -c '\du' | cut -d \| -f 1 | grep -qw $POSTGRES_USER ; then
      # user exists
      # $? is 0
      echo "pgsql user $POSTGRES_USER exists"
  else
    sudo -u postgres createuser $POSTGRES_USER
    sudo -u postgres createdb -E UTF8 -O $POSTGRES_USER gis
    sudo -u postgres psql -c "ALTER USER $POSTGRES_USER PASSWORD '${POSTGRES_PASSWORD}'"
  fi
}

if [ "$#" -ne 1 ]; then
    echo "usage: <run>"
    echo "commands:"
    echo "    run: Runs Geoserver"
    exit 1
fi

if [ "$1" = "run" ]; then
    # add handler for signal SIHTERM
    trap 'sighandler_TERM' 15

    createPostgresConfig
    initDb
    service postgresql start
    setPostgresPassword

    echo "wait for terminate signal"
    while [  "$STOP_CONT" = "no"  ] ; do
      sleep 1
    done

    exit 0
fi

echo "invalid command"
exit 1
