'''
Created on 08.02.2021

@author: Richard Kunzmann
'''

from django.db import connections
from django.http import JsonResponse
from django.http.response import HttpResponse

userdb_columns = ["user_name",
                  "forename",
                  "surname",
                  "acceptedEmailContact",
                  "organisation",
                  "country",
                  "language",
                  'phone']


def _queryhelper():
    out = ""
    for col_entry in userdb_columns:
        out += col_entry + ","
    return out[:-1]


def getCurrentUser(request):

    if request.method == 'GET':
        print('getCurrentUser: User von fetch: ', request.user)
        if request.user.is_authenticated:
            with connections['default'].cursor() as cursor:
                query = "select {} from user_profiles where user_name='{}'".format(_queryhelper(), request.user.username)
                cursor.execute(query)
                db_res = cursor.fetchone()
                user = dict()
                cnt = 0
                for col_entry in userdb_columns:
                    user[col_entry] = db_res[cnt]
                    cnt += 1

                retv = JsonResponse(user)

        else:
            retv = HttpResponse('Unauthorized', status=401)
    else:
        retv = HttpResponse('Bad Request', status=400)

    return retv
