'''
Created on 09.05.2021

@author: richard
'''


from django.http import HttpResponse
from django.db import connections
from org import to_decimal_string

import psycopg2
import logging

logger = logging.getLogger(__name__)

def nrTP (request):
     
    logger.debug('statistic: Track Points')

    try:
        with connections['depth'].cursor() as cursor:

            if request.user.is_authenticated:
                Query = ("select count (gid) from trackpoints_raw_filter_16;")
                cursor.execute(str(Query))
                db_count = cursor.fetchone()
                logger.debug('statistic - number of Track Points: {}'.format(db_count[0]))
            else:
                logger.debug('statistic - Users Count: no data')
            
    except (Exception, psycopg2.DatabaseError) as error:
        logger.debug(error)
        
    finally:
        if connections['depth'] is not None:
            connections['depth'].close()
            
        HttpResponse.status_code = 200
    return HttpResponse(to_decimal_string(str(db_count[0])))

