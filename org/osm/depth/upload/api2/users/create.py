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

import logging
logger = logging.getLogger(__name__)

def testfunc():
    logger.info("test info")
    logger.debug("test debug")
    logger.error("test error")
    logger.warning("test warning")
    
     
user = {}


def db_write (user):
    
    conn = psycopg2.connect(user="postgres",
                            password="osm",
                            host="127.0.0.1",
                            port="5432",
                            database="osmapi")
    cur = conn.cursor()

    new_user_profile = """INSERT INTO user_profiles (user_name, password, forename, surname, acceptedemailcontact, organisation, country, language, phone) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s) RETURNING id;"""
    cur.execute(new_user_profile, (user['username'], user['password'], user['forename'], user['surname'], user['acceptedEmailContact'], user['organisation'], user['country'], user['language'], user['phone'] ))
    return_id = cur.fetchone()[0]
    conn.commit()
    print('return_id', return_id)
    return
    
    
@csrf_exempt
@requires_csrf_token
def createUser(request):
    if request.method == 'POST':
        print('createUser: User von POST: ', request.POST['username'], '******')

        user['username']                = request.POST['username']
        user['password']                = request.POST['password']
        user['forename']                = request.POST['forename']
        user['surname']                 = request.POST['surname']
        user['acceptedEmailContact']    = request.POST['acceptedEmailContact']
        user['organisation']            = request.POST['organisation']
        user['country']                 = request.POST['country']
        user['language']                = request.POST['language']
        user['phone']                   = request.POST['phone']
        
#        print('User : ', user)
        
        db_write(user)



    
    return JsonResponse('ok', safe=False)

