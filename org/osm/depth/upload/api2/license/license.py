'''
Created on 28.02.2021

@author: Richard Kunzmann
'''
from django.http import HttpResponse
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token
#from django.contrib.auth import authenticate
#from django.db import models
from django.db import connections

import json
import psycopg2
import logging
from django.http.request import QueryDict
from pickle import NONE

logger = logging.getLogger(__name__)
    

@csrf_exempt
@requires_csrf_token
def getLicense(request):
    
    data_license  = {}
    data_licenses = [{}]
    
# Positionen der Daten im Record "license"
    lr_name = 0
    lr_shortname = 1
    lr_text = 2
    lr_public = 3
    lr_id = 4
    lr_user_name = 5
    
    with connections['osmapi'].cursor() as cursor:
        if request.method == 'GET':
            logger.debug('load License: for User: {}'.format(request.user))
            if request.user.is_authenticated:
                license_Query = ("select * from license;")
                cursor.execute(license_Query)
                license_record = cursor.fetchone()
                logger.debug('License : {}'.format(license_record))
            
                i = 0            
                while license_record is not None:            
            
                    data_license['name']         = license_record[lr_name]
                    data_license['shortname']    = license_record[lr_shortname]
                    data_license['text']         = license_record[lr_text]
                    data_license['public']       = license_record[lr_public]
                    data_license['id']           = license_record[lr_id]
                    data_license['user_name']    = license_record[lr_user_name]
            
                    data_licenses.insert(i, dict(data_license))
                    logger.debug('License[i]: bei {} = {}'.format(i, data_licenses[i]))
                    i += 1
                    license_record = cursor.fetchone()
                
                    data_licenses.pop()
            
    return JsonResponse(data_licenses, safe=False)


@csrf_exempt
@requires_csrf_token
def getBbox(request):

    try:
        if request.method == 'GET':
            lat1 = request.GET.get('lat1')
            lon1 = request.GET.get('lon1')
            lat2 = request.GET.get('lat2')
            lon2 = request.GET.get('lon2')
            logger.debug('License bbox Lat/Lon: {} {} {} {}'.format(lat1, lon1, lat2, lon2))

        with connections['depth'].cursor() as cursor:

                Query = ("SELECT DISTINCT datasetid FROM trackpoints_raw_8 WHERE trackpoints_raw_8.the_geom && ST_MakeEnvelope(%s, %s, %s, %s, 4326);")
                cursor.execute(str(Query),(lon1, lat1, lon2, lat2))
                db_license = cursor.fetchall()
                
                logger.debug("Tracks mit Lizenz: {}".format(len(db_license)))

                db_len = len(db_license)
                i=0
                buffer = ""
                
                while i < db_len:
                    elem = db_license[i]
                    buffer += "".join(str(elem[0]),) + ","
                    i += 1
                db_buffer = buffer.rstrip(",")
                logger.debug("Buffer: {}".format(db_buffer))

                if len(db_buffer) > 0:
                    with connections['osmapi'].cursor() as cursor:
                        Query = ("SELECT shortname FROM license INNER JOIN (SELECT DISTINCT license FROM user_tracks WHERE track_id IN (" + db_buffer + ") ) l2 ON license.id = l2.license")
                        cursor.execute(str(Query),)
                        db_license = cursor.fetchall()

                        logger.debug("Anzahl Lizenzen: {}, Lizenz Typen: {}".format(len(db_license), db_license))

                        db_len = len(db_license)
                        i=0
                        buffer = ""
                        ls_buffer = "keine"
                    
                        while i < db_len:
                            elem = db_license[i]
                            buffer += "".join(str(elem[0]),) + ","
                            i += 1
                        ls_buffer = buffer.rstrip(",")
                        logger.debug("Lizenzen: {}".format(ls_buffer))
                else:
                    ls_buffer = "keine Track Lizenz"
                    logger.debug("Lizenzen: {}".format(ls_buffer))
                    
    except (Exception, psycopg2.DatabaseError) as error:
        logger.debug(error)

    finally:
        if connections['depth'] is not None:
            connections['depth'].close()
        if connections['osmapi'] is not None:
            connections['osmapi'].close()
    
        HttpResponse.status_code = 200    
        return HttpResponse(ls_buffer)

