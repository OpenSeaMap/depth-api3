'''
Created on 28.02.2021

@author: Richard Kunzmann
'''
#from django.http import HttpResponse
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token
#from django.contrib.auth import authenticate
#from django.db import models

import json
import psycopg2



@csrf_exempt
@requires_csrf_token
def getLicense(request):
    
    data_license  = {}
    data_licenses = [{}]
    
    conn = psycopg2.connect(user="postgres",
                    password="osm",
                    host="127.0.0.1",
                    port="5432",
                    database="osmapi")
    cur = conn.cursor()

    if request.method == 'GET':
        print('load License: for User: ', request.user)
        if request.user.is_authenticated:
            license_Query = ("select * from license;")
            cur.execute(license_Query)
            license_record = cur.fetchone()
            print('License : ', license_record)
            
            i = 0            
            while license_record is not None:            
            
                data_license['name']         = license_record[0]
                data_license['shortname']    = license_record[1]
                data_license['text']         = license_record[2]
                data_license['public']       = license_record[3]
                data_license['id']           = license_record[4]
                data_license['user_name']    = license_record[5]
            
                data_licenses.insert(i, dict(data_license))
                print('License[i]: bei ',i ,' = ', data_licenses[i])
                i += 1
                license_record = cur.fetchone()
                
            data_licenses.pop()
            
#    return JsonResponse('ok', safe=False)
    return JsonResponse(data_licenses, safe=False)

