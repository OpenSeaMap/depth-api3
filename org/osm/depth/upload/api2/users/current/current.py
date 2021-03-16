'''
Created on 08.02.2021

@author: Richard Kunzmann
'''

#from django.http import HttpResponse
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token
#from django.contrib.auth import authenticate
#from django.db import models

#import json
import psycopg2
 
#user = {}


def db_read (db_cur_user):
    conn = psycopg2.connect(user="postgres",
                            password="osm",
                            host="127.0.0.1",
                            port="5432",
                            database="osmapi")
    cur = conn.cursor()

    xx = "{}".format(db_cur_user)
#    print('xx = :',xx)
    postgreSQL_select_Query = ("select * from user_profiles where user_name='%s' ;" %xx )
    cur.execute(str(postgreSQL_select_Query))
#   cur.execute("select * from user_profiles where user_name=? ;", xx )
    db_user = cur.fetchone()

    return db_user
    
    
@csrf_exempt
@requires_csrf_token
def getCurrentUser(request):
    user = {}

    if request.method == 'GET':
        print('getCurrentUser: User von fetch: ', request.user)
        if request.user.is_authenticated:
            print('fetch DB und zeige das current Model von User', request.user)
#            print('user : ',user)
#            db_read(user['user_name'])
            db_user = db_read(request.user)
        else:
            db_user = {}
    
    user['user_name']           = db_user[0]
    user['forename']             = db_user[5]
    user['surname']             = db_user[6]
    user['acceptedEmailContact']= db_user[11]                         # boolean (True in der DB wird zu 1)
    user['organisation']        = db_user[9]
    user['country']             = db_user[7]
    user['language']            = db_user[8]
    user['phone']               = db_user[10]
    
    return JsonResponse(user)

