#!/bin/bash

set -x

STOP_CONT="no"

SRC_DIR="/data/"
PRJ_DIR="/data/depth-api3"
ENV_FILE="/data/depth-api3/depth3/.env"


# handler for term signal
function sighandler_TERM() {
    echo "signal SIGTERM received\n"
    STOP_CONT="yes"
}

function gen_env(){
	echo "DEBUG=$DEBUG"                                                     > $ENV_FILE
	echo "SECRET_KEY=$SECRET_KEY"                                          >> $ENV_FILE
	echo ""                                                                >> $ENV_FILE
	echo "# database used for django server"                               >> $ENV_FILE
	echo "DB_ENGINE=$DB_ENGINE"                                            >> $ENV_FILE
	echo "DB_NAME=$DB_NAME"                                                >> $ENV_FILE
	echo "DB_USER=$DB_USER"                                                >> $ENV_FILE
	echo "DB_PASSWORD=$DB_PASSWORD"                                        >> $ENV_FILE
	echo "DB_HOST=$DB_HOST"                                                >> $ENV_FILE
	echo "DB_PORT=$DB_PORT"                                                >> $ENV_FILE
	echo ""                                                                >> $ENV_FILE
	echo "# database used from API2 backend (java / tomcat version)"       >> $ENV_FILE
	echo "DB_OSMAPI_ENGINE=$DB_OSMAPI_ENGINE"                              >> $ENV_FILE
	echo "DB_OSMAPI_NAME=$DB_OSMAPI_NAME"                                  >> $ENV_FILE
	echo "DB_OSMAPI_USER=$DB_OSMAPI_USER"                                  >> $ENV_FILE
	echo "DB_OSMAPI_PASSWORD=$DB_OSMAPI_PASSWORD"                          >> $ENV_FILE
	echo "DB_OSMAPI_HOST=$DB_OSMAPI_HOST"                                  >> $ENV_FILE
	echo "DB_OSMAPI_PORT=$DB_OSMAPI_PORT"                                  >> $ENV_FILE
	echo ""                                                                >> $ENV_FILE
	echo "# database used from API2 backend (java / tomcat version)"       >> $ENV_FILE
	echo "DB_DEPTH_ENGINE=$DB_DEPTH_ENGINE"                                >> $ENV_FILE
	echo "DB_DEPTH_NAME=$DB_DEPTH_NAME"                                    >> $ENV_FILE
	echo "DB_DEPTH_USER=$DB_DEPTH_USER"                                    >> $ENV_FILE
	echo "DB_DEPTH_PASSWORD=$DB_DEPTH_PASSWORD"                            >> $ENV_FILE
	echo "DB_DEPTH_HOST=$DB_DEPTH_HOST"                                    >> $ENV_FILE
	echo "DB_DEPTH_PORT=$DB_DEPTH_PORT"                                    >> $ENV_FILE
	echo ""                                                                >> $ENV_FILE
	echo "# email configuration"                                           >> $ENV_FILE
	echo "EMAIL_BACKEND=$EMAIL_BACKEND"                                    >> $ENV_FILE
	echo "EMAIL_HOST=$EMAIL_HOST"                                          >> $ENV_FILE
	echo "EMAIL_PORT=$EMAIL_PORT"                                          >> $ENV_FILE
	echo "EMAIL_HOST_USER=$EMAIL_HOST_USER"                                >> $ENV_FILE
	echo "EMAIL_HOST_PASSWORD=$EMAIL_HOST_PASSWORD"                        >> $ENV_FILE
	echo ""                                                                >> $ENV_FILE
	echo "UPLOAD_PATH=$UPLOAD_PATH"                                        >> $ENV_FILE
  echo "LOGFILENAME=$LOGFILENAME"                                        >> $ENV_FILE
}

if [ "$#" -ne 1 ]; then
    echo "usage: <run>"
    echo "commands:"
    echo "    run: Run Django"
    echo "migrate: Migrate Dajngo Model"
    exit 1
fi

if [ "$1" = "run" ]; then
    # add handler for signal SIHTERM
    trap 'sighandler_TERM' 15

    # prepare start of server
    gen_env

    # start server
	cd /data/depth-api3
    python3 manage.py runserver 0.0.0.0:8000

    echo "wait for terminate signal"
    while [  "$STOP_CONT" = "no"  ] ; do
      sleep 1
    done

    exit 0
fi

if [ "$1" = "migrate" ]; then
    # add handler for signal SIHTERM
    trap 'sighandler_TERM' 15

    # prepare start of server
    gen_env

    # start server
	cd /data/depth-api3
    python3 manage.py migrate

    exit 0
fi

echo "invalid command"
exit 1
