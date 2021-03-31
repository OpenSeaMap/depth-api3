'''
Created on 08.02.2021

@author: Richard Kunzmann
'''

from django.db import connections
from django.http import JsonResponse
from django.http.response import HttpResponse
from org import _queryhelper, userdb_columns

import logging


logger = logging.getLogger(__name__)


def getCurrentUser(request):

    if request.method == 'GET':
        logging.debug('getCurrentUser: User von fetch: {}'.format(request.user))
        if request.user.is_authenticated:
            with connections['osmapi'].cursor() as cursor:
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
