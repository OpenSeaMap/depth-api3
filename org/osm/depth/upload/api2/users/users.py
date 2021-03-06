'''
Created on 06.03.2021

@author: Richard Kunzmann
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
def createUser(request):
    if request.method == 'POST':
        print('createUser: User von POST: ', request.user)
        print('fetch DB und zeige das current Model von User', request.body.decode('ascii'))
#        user = json.loads(request.body)
        str1 = request.body.decode('utf-8')
        str2 = str1.split('&')
        print(str2)
#        db_write(user)
        x = str2([0]).split('=')
        print(x[1])
        y = str2([1]).split('=')
        print(y[1])
        print(str2[2])
        print(str2[3])



    
    return JsonResponse('ok', safe=False)

