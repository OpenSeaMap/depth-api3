'''
Created on 28.02.2021

@author: richard
'''
from django.http import HttpResponse
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token
from django.db import connections

import json
import psycopg2
import logging

logger = logging.getLogger(__name__)

 
user = {}

def db_write (user):

    with connections['osmapi'].cursor() as cursor:
        new_user_profile = """UPDATE user_profiles set forename=%s, surname=%s, acceptedEmailContact=%s, organisation=%s, country=%s, language=%s, phone=%s;"""
        cursor.execute(new_user_profile, (user['forename'], user['surname'], user['acceptedEmailContact'], user['organisation'], user['country'], user['language'], user['phone'] ))
        connections['osmapi'].commit()
    
    return
    
    
@csrf_exempt
@requires_csrf_token
def putCurrentUser(request):
    if request.method == 'PUT':
        if request.user.is_authenticated:
            logger.debug('fetch DB und zeige das current Model von User {}'.format(request.body))
            user = json.loads(request.body)
            db_write(user)
            return JsonResponse(user)
        else:
            logger.debug('Hmmm ... User ist nicht autentifiziert')
            HttpResponse.status_code = 409                      # 409 = conflict
            return HttpResponse("nein")
    else:
        HttpResponse.status_code = 501
        return HttpResponse("request method not implemented")
    
    