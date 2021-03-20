'''
Created on 28.02.2021

@author: Richard Kunzmann
'''

from django.http import HttpResponse
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token
from django.db import connections

import psycopg2
import json
import logging

logger = logging.getLogger(__name__)

@csrf_exempt
@requires_csrf_token
def getTrack(request):
    
    track = {}
    tracks = [{}]

    try:
        with connections['osmapi'].cursor() as cursor:

            if request.method == 'GET':
#                print('load Tracks: for User: ', request.user)
                if request.user.is_authenticated:
                    track_Query = ("select * from user_tracks where user_name=%s;")
                    cursor.execute(track_Query, ("{}".format(request.user),))
                    track_record = cursor.fetchone()
#                    print('Track : ', track_record)
            
                    i = 0            
                    while track_record is not None:            
                        track['id']             = track_record[0]
                        track['user_name']      = track_record[1]
                        track['fileName']       = track_record[2]
                        track['upload_state']   = track_record[3]
                        track['fileType']       = track_record[4]
                        track['compression']    = track_record[5]
                        track['containertrack'] = track_record[6]
                        track['vesselconfigid'] = track_record[7]
                        track['license']        = track_record[8]
                        track['gauge_name']     = track_record[9]
                        track['gauge']          = track_record[10]
                        track['height_ref']     = track_record[11]
                        track['comment']        = track_record[12]
                        track['watertype']      = track_record[13]
                        track['uploaddate']     = track_record[14]
                        track['bbox']           = track_record[15]
                        track['clusteruuid']    = track_record[16]
                        track['clusterseq']     = track_record[17]
                        track['upr_id']         = track_record[18]
                        track['num_points']     = track_record[19]
                        track['is_container']   = track_record[20]
                    
                        tracks.insert(i, dict(track))
#                        print('tracks[i]: bei ',i ,' = ', track[i])
                        i += 1
                        track_record = cursor.fetchone()
                        logger.debug('Track : von I = {}  {}'.format(i, track))
                        
                tracks.pop()

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        
    finally:
        if connections['osmapi'] is not None:
            connections['osmapi'].close()
    
    return JsonResponse(tracks, safe=False)
   
    
