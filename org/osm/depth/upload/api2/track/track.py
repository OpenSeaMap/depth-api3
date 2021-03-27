'''
Created on 28.02.2021

@author: Richard Kunzmann
'''

from django.http import HttpResponse
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token
from django.db import connections
from datetime import datetime as dt

import psycopg2
import logging
import json

logger = logging.getLogger(__name__)

@csrf_exempt
@requires_csrf_token
def getTrack(request):

#------------------------------------------------
#
#    Track laden Schritt 1.
#    
    track = {}
    tracks = [{}]

    if request.method == 'GET':
        logging.debug('\nMethod GET:  load Tracks: for User: {}'.format(request.user))
        try:
            with connections['osmapi'].cursor() as cursor:

                if request.user.is_authenticated:
                    track_Query = ("SELECT * FROM v_user_tracks u LEFT OUTER JOIN vesselconfiguration v ON u.vesselconfigid = v.id WHERE u.user_name=%s ORDER BY track_id desc;")
                    cursor.execute(track_Query, ("{}".format(request.user),))
                    track_record = cursor.fetchone()
                    logging.debug('Track : {}'.format(track_record))
            
                    i = 0            
                    while track_record is not None:            
                        track['id']             = track_record[0]
                        track['fileName']       = track_record[2]
                        track['fileType']       = track_record[4]
                        track['compression']    = track_record[5]
                        track['containertrack'] = track_record[6]
                        track['license']        = track_record[8]
                        track['upload_state']   = track_record[3]
                        track['vesselconfigid'] = track_record[7]
                        track['uploaddate']     = track_record[14]
                        track['num_points']     = track_record[19]
                        track['track_info']     = track_record[21]
                        track['left']           = track_record[22]
                        track['right']          = track_record[23]
                        track['top']            = track_record[24]
                        track['bottom']         = track_record[25]
                    
                        tracks.insert(i, dict(track))
#                        print('tracks[i]: bei ',i ,' = ', track[i])
                        i += 1
                        track_record = cursor.fetchone()
#                        logger.debug('Track : von I = {}  {}'.format(i, track))
                        
                tracks.pop()

        except (Exception, psycopg2.DatabaseError) as error:
            logging.debug(error)
        
        finally:
            if connections['osmapi'] is not None:
                connections['osmapi'].close()
    
        return JsonResponse(tracks, safe=False)



#------------------------------------------------
#
#    Track speichern Schritt 1.
#
    if request.method == 'POST':
        logging.debug('\nMethod POST:  store Tracks: for User: {}'.format(request.user))
        try:
            with connections['osmapi'].cursor() as cursor:

                if request.user.is_authenticated:
                    track_data = json.loads(request.body)
                    logging.debug('Track_data: {} '.format(track_data))
                    
                    vessel_Query = ("SELECT id FROM vesselconfiguration WHERE user_name=%s AND id=%s;")
                    cursor.execute(vessel_Query, (str(request.user), track_data['vesselconfigid']),)
                    vessel_id = cursor.fetchone()
                    
                    license_Query = ("SELECT id FROM license WHERE (user_name = %s OR public = 'true') AND id = %s;")
                    cursor.execute(license_Query, (str(request.user), track_data['license']),)
                    license_id = cursor.fetchone()
                    
#                    print('vessel_id: ',vessel_id, ' license_id: ', license_id)
                    logging.debug('vessel_id: {} license_id: {}'.format(vessel_id, license_id))
                    if int(vessel_id[0]) and int(license_id[0]):                    # tuple nach int convertieren
                        logging.debug('OK vessel_id und license_id sind vorhanden')
                        new_trackid = ("SELECT nextval('user_tracks_track_id_seq');")
                        cursor.execute(new_trackid)
                        trackid = cursor.fetchone()
                        
                        track_Query = ("INSERT INTO user_tracks (track_id, user_name, uploaddate, vesselconfigid , license, file_ref ) VALUES (%s, %s, %s, %s, %s, %s);");
                        cursor.execute(track_Query,(trackid[0], str(request.user), dt.now().isoformat(), track_data['vesselconfigid'], track_data['license'], track_data['fileName']))
                        connections['osmapi'].commit()                      # Wichtig: commit the changes to the database
                        
                    print('Track : stored', dt.now().isoformat())



        except (Exception, psycopg2.DatabaseError) as error:
            logging.debug(error)
        
        finally:
            if connections['osmapi'] is not None:
                connections['osmapi'].close()
                
            return JsonResponse(int(trackid[0]), safe=False)


#------------------------------------------------
#
#    Track speichern Schritt 2
#

    if request.method == 'PUT':
        print('\nMethod PUT:  store Tracks: for User: {}'.format(request.user))
        try:
            with connections['osmapi'].cursor() as cursor:

                if request.user.is_authenticated:
                    # Datei laden
                    # da weiß ich aber noch nicht wie es geht
                    #
                    length=len(request.body)
                    logging.debug('len = {}'.format(length)) 
                    xx = request.body.decode("utf-8")
                    logging.debug('Track_data: {}'.format(xx))
                    
                    x1 = xx.split('\r\n',1)                         # abtrennen: '------WebKitFormBoundaryP1coSr2qFeAFoAO8\r\n'
                    x2 = x1[1].split('\r\n',1)                      # abtrennen: 'Content-Disposition: form-data; name="track"; filename="DATA0030.DAT"\r\n' 
                    x3 = x2[1].split('\r\n\r\n',1)                  # abtrennen: 'Content-Type: application/octet-stream\r\n\r\n'  
                    
                    print('x1 : ', x1[0],';  x2 : ', x2[0], ';  x3 : ', x3[0])
                    
#                    z = x3[1].encode('utf-8')                       # change str back to byte
                    z = x3[1]
                    data = z.split('\r\n------',1)                  # abtrennen am Ende: '------WebKitFormBoundaryP1coSr2qFeAFoAO8\r\n'
                    y = x2[0].split('filename="',1)
                    name = y[1].split('"',1)
#                    f = open(name[0], "wb+")                        # müssen wir in binary schreiben? Die NMEA Daten sind eigentlich String
                    f = open(name[0], "w")
                    f.write(data[0])
                    f.close()
                    
                    t_id_Query = ("SELECT track_id FROM user_tracks WHERE file_ref=%s AND user_name=%s AND upload_state='0';")
                    cursor.execute(t_id_Query, (name[0], str(request.user)),)
                    track_id = cursor.fetchone()

                    t_id_Set = ("UPDATE user_tracks SET upload_state = 1 WHERE track_id=%s;")
                    cursor.execute(t_id_Set, (track_id))

        except (Exception, psycopg2.DatabaseError) as error:
            print(error)
        
        finally:
            if connections['osmapi'] is not None:
                connections['osmapi'].close()
                
            HttpResponse.status_code = 200
            return HttpResponse("OK")


@csrf_exempt
@requires_csrf_token
def deleteTrack(request, null):
    
    if request.method == 'DELETE':
        logging.debug('\nDelete Track: {}'.format(null))
        try:
            with connections['osmapi'].cursor() as cursor:
        
                del_track_Query = "DELETE from user_tracks where track_id=%s AND user_name=%s;"
                cursor.execute(del_track_Query, (null, "{}".format(request.user)))
                connections['osmapi'].commit()                      # Wichtig: commit the changes to the database 
                
                # Das muss noch gemacht werden.
                # Wie werden diese Felder überhaupt befüllt
                #
                # "DELETE FROM trackpoints_raw_8 WHERE datasetid = ?"  trackId
                # "DELETE FROM trackpoints_raw_10 WHERE datasetid = ?"
                # "DELETE FROM trackpoints_raw_12 WHERE datasetid = ?"
                # "DELETE FROM trackpoints_raw_16 WHERE datasetid = ?"
                # "DELETE FROM trackpoints_raw_filter_8 WHERE datasetid = ?"
                # "DELETE FROM trackpoints_raw_filter_10 WHERE datasetid = ?"
                # "DELETE FROM trackpoints_raw_filter_12 WHERE datasetid = ?"
                # "DELETE FROM trackpoints_raw_filter_16 WHERE datasetid = ?"
        
        except (Exception, psycopg2.DatabaseError) as error:
            logging.debug(error)
        
        finally:
            if connections['osmapi'] is not None:
                connections['osmapi'].close()
        
            HttpResponse.status_code = 200
            return HttpResponse("OK")





