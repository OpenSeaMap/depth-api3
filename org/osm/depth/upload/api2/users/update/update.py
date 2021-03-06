'''
Created on 28.02.2021

@author: richard
'''
#from django.http import HttpResponse
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token
#from django.contrib.auth import authenticate
#from django.db import models

import json
import psycopg2
 
user = {}


def db_write (user):
    
    conn = psycopg2.connect(user="postgres",
                            password="osm",
                            host="127.0.0.1",
                            port="5432",
                            database="osmapi")
    cur = conn.cursor()

    new_user_profile = """UPDATE user_profiles set forename=%s, surname=%s, acceptedEmailContact=%s, organisation=%s, country=%s, language=%s, phone=%s;"""
    cur.execute(new_user_profile, (user['forename'], user['surname'], user['acceptedEmailContact'], user['organisation'], user['country'], user['language'], user['phone'] ))
    conn.commit()
    
    return
    
    
@csrf_exempt
@requires_csrf_token
def putCurrentUser(request):
    if request.method == 'PUT':
        print('update CurrentUser: User von fetch: ', request.user)
        if request.user.is_authenticated:
            print('fetch DB und zeige das current Model von User', request.body)
#            print('user : ',user)
#            db_read(user['user_name'])
            user = json.loads(request.body)
            db_write(user)
#        else:
#            db_user = {}
    
    return JsonResponse(user)

