#!/bin/bash

docker build -t geoserver-gebco src/geoserver
docker build -t postgis:2.3 src/postgis/2.3
docker build -t osmapi:2.5 src/osmapi/2.5
