'''
Created on 30.03.2021

@author: Richard Kunzmann
'''

from django.http import HttpResponse
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token
from django.db import connections
from datetime import datetime as dt

import psycopg2
import logging
import json
import time
import datetime

logger = logging.getLogger(__name__)


#
#    aktuelle Pegelstände können von www.Pegelonline.wsv.de in verschiedenen Formen herunter geladen werden.
#    dies war einmal vorgesehen, kam jedoch aus einer frühen Testphase nicht heraus
#    und wurde zunächst nicht weiter verfolgt
#    Sollte in einer späteren Version verfolgt werden.
#

@csrf_exempt
@requires_csrf_token
def getGauges(request):
    
#------------------------------------------------
#
#    verfügbare Pegen von der Datenbank laden und den Frontend zur Visualisierung übergeben
#    
    gauge = {}
    gauges = [{}]

    if request.method == 'GET':
        logger.debug('\nMethod GET:  load Gauges: for User: {}'.format(request.user))
        try:
            with connections['osmapi'].cursor() as cursor:
                if request.user.is_authenticated:
#                    gauge_Query = ("SELECT id, name, gaugetype, waterlevel, ST_AsText(geom) as geom FROM gauge g;")
                    gauge_Query = ("SELECT id, name, gaugetype, waterlevel, lat, lon FROM gauge;")
                    cursor.execute(gauge_Query, ("{}".format(request.user),))
                    gauge_record = cursor.fetchone()
                    logger.debug('Gauge : {}'.format(gauge_record))
            
                    i = 0            
                    while gauge_record is not None:            
                        gauge['id']         = gauge_record[0]
                        gauge['name']       = gauge_record[1]
                        gauge['latitude']   = gauge_record[4]
                        gauge['longitude']  = gauge_record[5]
                        gauge['gaugeType']  = gauge_record[2]
                        gauge['waterlevel'] = gauge_record[3]

                        gauges.insert(i, dict(gauge))
                        i += 1
                        gauge_record = cursor.fetchone()
                        logger.debug('Gauge : von I = {}  {}'.format(i, gauge))
                        
                gauges.pop()
                    
        except (Exception, psycopg2.DatabaseError) as error:
            logger.debug(error)
        
        finally:
            if connections['osmapi'] is not None:
                connections['osmapi'].close()
        
            HttpResponse.status_code = 200
#            return HttpResponse("OK")
            return JsonResponse(gauges, safe=False)  


@csrf_exempt
@requires_csrf_token
def getGaugeMeasurement(request, null):
    
#------------------------------------------------
#
#    spezifischen Pegelstand von der Datenbank laden und dem Frontend zur Visualisierung übergeben 
#
    list = {}
    lists = [{}]
    
    if request.method == 'GET':
        logger.debug('\nMethod GET:  load Gauge Measurement: of Gauge: {} - for User: {}'.format(null, request.user))
        try:
            with connections['osmapi'].cursor() as cursor:
                if request.user.is_authenticated:
                    list_Query = ("SELECT gaugeid, value, time FROM gaugemeasurement g WHERE gaugeid = %s ORDER BY time DESC;")
                    cursor.execute(list_Query, ("{}".format(null),))     # 673
                    list_record = cursor.fetchone()
                    logger.debug('Gauge : {}'.format(list_record))
            
                    i = 0                   
                    while list_record is not None:            
                        list['gaugeId']     = list_record[0]
                        list['value']       = list_record[1]
                        list['timestamp']   = int(time.mktime(datetime.datetime.strptime(str(list_record[2]), "%Y-%m-%d %H:%M:%S").timetuple()))*1000
                        list['lengthunit']  = str('METERS')

#                        Achtung:
#                        mktime() geht immer von der lokalen Zeitzone aus.
#                        Da mir derzeit nicht bekannt ist, in welcher Zeitzone die alten Daten der DB liegen
#                        habe ich zunächst auf eine Umrechnung nach UTC verzichtet
                
                        lists.insert(i, dict(list))
                        i += 1
                        list_record = cursor.fetchone()
#                        logger.debug('Gauge : von I = {}  {}'.format(i, list))
                        
                lists.pop()                
                
        except (Exception, psycopg2.DatabaseError) as error:
            logger.debug(error)
        
        finally:
            if connections['osmapi'] is not None:
                connections['osmapi'].close()
        
            HttpResponse.status_code = 200
#            return HttpResponse("OK")
            return JsonResponse(lists, safe=False)  
              
              
                
                          
        