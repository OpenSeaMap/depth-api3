'''
Created on 02.05.2021

@author: Richard Kunzmann
'''

from django.http import HttpResponse
from django.db import connections
from org import to_decimal_string


import psycopg2
import logging

logger = logging.getLogger(__name__)

def nrd3u (request):
     
    logger.debug('statistic:')

    try:
        with connections['osmapi'].cursor() as cursor:

            if request.user.is_authenticated:
                Query = ("select count (user_name) from user_profiles;")
                cursor.execute(str(Query))
                db_count = cursor.fetchone()
                logger.debug('statistic - Users Count: {}'.format(db_count[0]))
            else:
                logger.debug('statistic - Users Count: no data')
            
    except (Exception, psycopg2.DatabaseError) as error:
        logger.debug(error)
        
    finally:
        if connections['osmapi'] is not None:
            connections['osmapi'].close()
            
        HttpResponse.status_code = 200
    return HttpResponse(to_decimal_string(str(db_count[0])))


