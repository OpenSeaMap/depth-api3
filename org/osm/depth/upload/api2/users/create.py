'''
Created on 06.03.2021

@author: Richard Kunzmann
'''

from django.db import connections
from django.http import HttpResponse
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token
#from django.contrib.auth import authenticate
#from django.db import models

import json
import psycopg2

import logging
logger = logging.getLogger(__name__)

user = {}


def db_write (user):

    with connections['osmapi'].cursor() as cursor:

        new_user_profile = """INSERT INTO user_profiles (user_name, password, forename, surname, acceptedemailcontact, organisation, country, language, phone) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s) RETURNING id;"""
        cursor.execute(new_user_profile, (user['username'], user['password'], user['forename'], user['surname'], user['acceptedEmailContact'], user['organisation'], user['country'], user['language'], user['phone'] ))
        return_id = cursor.fetchone()[0]
        connections['osmapi'].commit()
        
    logger.debug('New user return_id = {}'.format(return_id))
    return
    
    
@csrf_exempt
@requires_csrf_token
def createUser(request):
    
    if (request.POST['captcha'] != request.session['captcha_rk']):  # Stimmt das gesendete captcha mit dem eingegebenen überein?
        HttpResponse.status_code = 401                              # 401 = captcha falsch: Unauthorized access
        return HttpResponse('Captcha did not match')

    if request.method == 'POST':
        user['username']                = request.POST['username']
        user['password']                = request.POST['password']
        user['forename']                = request.POST['forename']
        user['surname']                 = request.POST['surname']
        user['acceptedEmailContact']    = request.POST['acceptedEmailContact']
        user['organisation']            = request.POST['organisation']
        user['country']                 = request.POST['country']
        user['language']                = request.POST['language']
        user['phone']                   = request.POST['phone']
        
        logger.debug('Record neuer User: {}'.format(user))
        db_write(user)

        HttpResponse.status_code = 200                              # 
        return HttpResponse('ok')

