'''
Created on 28.02.2021

@author: Richard Kunzmann
'''
#from django.http import HttpResponse
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token
#from django.contrib.auth import authenticate
#from django.db import models
from django.db import connections

import json
import psycopg2
import logging


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
    
    logger = logging.getLogger(__name__)
    
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

