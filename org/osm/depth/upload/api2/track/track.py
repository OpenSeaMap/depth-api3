'''
Created on 28.02.2021

@author: Richard Kunzmann
'''

from django.http import HttpResponse
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token
from django.db import connections
from datetime import datetime as dt
from depth3.settings import UPLOAD_PATH

import datetime
import time
import psycopg2
import logging
import json
import os
import calendar
import ciso8601


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
#                    print('DB-Time-return: ',track_record[14], 'Test-Stamp: ',int(calendar.timegm(datetime.datetime.strptime(str(track_record[14]), "%Y-%m-%d %H:%M:%S.%f").timetuple()))*1000)
            
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
                        if track_record[14] != None:
#                            track['uploadDate'] = int(time.mktime(datetime.datetime.strptime(str(track_record[14]), "%Y-%m-%d %H:%M:%S.%f").timetuple()))*1000
                            track['uploadDate'] = int(time.mktime(ciso8601.parse_datetime(str(track_record[14])).timetuple())*1000)     # soll wesentlich schneller sein
                        else:
                            track['uploadDate'] = 0                     # da der HW-Logger kein File-Datum schreibt wird in die DB die Time-Periode 0 eingetragen, also 1970
                        
                        track['num_points']     = track_record[19]
                        track['track_info']     = track_record[21]
                        track['left']           = track_record[22]
                        track['right']          = track_record[23]
                        track['top']            = track_record[24]
                        track['bottom']         = track_record[25]
                    
                        tracks.insert(i, dict(track))
#                        logging.debug('tracks[i]: bei {} = {}'.format(i, track[i]))
                        i += 1
                        track_record = cursor.fetchone()
#                        logger.debug('Track : von I = {}  {}'.format(i, track))
                        
                tracks.pop()

        except (Exception, psycopg2.DatabaseError) as error:
            logging.debug('Exception: {}'.format(error))
        
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
                    
                    logging.debug('vessel_id: {}; license_id: {};'.format(vessel_id, license_id))
                    if int(vessel_id[0]) and int(license_id[0]):                    # tuple nach int convertieren
                        logging.debug('OK vessel_id und license_id sind vorhanden')
                        new_trackid = ("SELECT nextval('user_tracks_track_id_seq');")
                        cursor.execute(new_trackid)
                        trackid = cursor.fetchone()
                        
                        track['uploaddate'] = dt.now().isoformat()
                        track_Query = ("INSERT INTO user_tracks (track_id, user_name, uploaddate, vesselconfigid , license, file_ref ) VALUES (%s, %s, %s, %s, %s, %s);");
                        cursor.execute(track_Query,(trackid[0], str(request.user), track['uploaddate'], track_data['vesselconfigid'], track_data['license'], track_data['fileName']))
                        connections['osmapi'].commit()                      # Wichtig: commit the changes to the database
                        
                    logging.debug('Track : stored at {}'.format(dt.now().isoformat()))

        except (Exception, psycopg2.DatabaseError) as error:
            logging.debug(error)
        
        finally:
            if connections['osmapi'] is not None:
                connections['osmapi'].close()
                
            track['id']             = trackid[0]
            track['fileName']       = track_data['fileName']
#            track['fileType']       = 0
#            track['compression']    = 0
            track['containertrack'] = 0
            track['license']        = 1
            track['upload_state']   = 0
            track['vesselconfigid'] = track_data['vesselconfigid']
            track['uploaddate']     = track['uploaddate']
            track['num_points']     = 0
#            track['track_info']     = 0
            track['left']           = 0
            track['right']          = 0
            track['top']            = 0
            track['bottom']         = 0
            
            HttpResponse.status_code = 200
            return JsonResponse(track, safe=False)


#------------------------------------------------
#
#    Track speichern Schritt 2
#

    if request.method == 'PUT':
        logging.debug('\nMethod PUT:  store Tracks: for User: {}'.format(request.user))
        try:
            with connections['osmapi'].cursor() as cursor:

                if request.user.is_authenticated:
                    # Datei laden
                    #
                    length=len(request.body)
                    logging.debug('len = {}'.format(length)) 
                    xx = request.body.decode("utf-8")
#                    logging.debug('Track_data: {}'.format(xx))
                    
                    x1 = xx.split('\r\n',1)                         # abtrennen: '------WebKitFormBoundaryP1coSr2qFeAFoAO8\r\n'
                    x2 = x1[1].split('\r\n',1)                      # abtrennen: 'Content-Disposition: form-data; name="track"; filename="DATA0030.DAT"\r\n' 
                    x3 = x2[1].split('\r\n\r\n',1)                  # abtrennen: 'Content-Type: application/octet-stream\r\n\r\n'  
                    
#                    logging.debug('x1 : {};  x2 : {};  x3 : {};'.format(x1[0], x2[0], x3[0]))
                    
#                    z = x3[1].encode('utf-8')                       # change str back to byte
                    z = x3[1]
                    data = z.split('\r\n------',1)                  # abtrennen am Ende: '------WebKitFormBoundaryP1coSr2qFeAFoAO8\r\n'
                    y = x2[0].split('filename="',1)
                    name = y[1].split('"',1)
                    
                    t_id_Query = ("SELECT track_id FROM user_tracks WHERE file_ref=%s AND user_name=%s AND upload_state='0';")
                    cursor.execute(t_id_Query, (name[0], str(request.user)),)
                    track_id = cursor.fetchone()

                    t_id = int(''.join(map(str, track_id)))         # tuple to integer
                    writeData(data[0], t_id)                        # write Date to file

                    t_id_Set = ("UPDATE user_tracks SET upload_state = 1 WHERE track_id=%s;")
                    cursor.execute(t_id_Set, (track_id))

        except (Exception, psycopg2.DatabaseError) as error:
            logging.debug(error)
        
        finally:
            if connections['osmapi'] is not None:
                connections['osmapi'].close()
                
#            logging.debug(len(data[0]))
            HttpResponse.status_code = 200
            return HttpResponse(len(data[0]))                       # hier soll die Länge der Datei an das Frontend zurück gegeben werden

#
#    schreibe die Daten in eine Datei, die als Namen die "Track ID" trägt mit der Ext. ".dat"
#    dabei werden die Dateien, deren Track ID im gleichen 100er Bereich liegen, in eine eigene Directory geschrieben.
#    wir hoffen, damit eine bessere Übersicht zu bekommen.
#
def writeData(data, track_id):
    if track_id < 100:
        nr = '000'
    else:
        x = track_id // 100     # ganzzahlige Division
        nr = str(x) + '00'

    try:
        filePath = UPLOAD_PATH + nr + "/"
        fileName = UPLOAD_PATH + nr + "/" + str(track_id) + ".dat"
        if not os.path.exists(filePath):
            os.makedirs(filePath)
            
        file = open(fileName, "w")                                  # "wb+" müssen wir in binary schreiben? Die NMEA Daten sind eigentlich String
        file.write(data)
        
    except (Exception) as error:
            logging.debug(error)
            
    finally:
        file.close()
        return

@csrf_exempt
@requires_csrf_token
def deleteTrack(request, null):
    
    trackId = null
    
    if request.method == 'DELETE':
        logging.debug('\nDelete Track: {}'.format(trackId))
        try:
            with connections['osmapi'].cursor() as cursor:
        
                del_track_Query = "DELETE from user_tracks where track_id=%s AND user_name=%s;"
                cursor.execute(del_track_Query, (trackId, "{}".format(request.user)))
                connections['osmapi'].commit()                      # Wichtig: commit the changes to the database 
                
#
#    Wir müssen die Frage noch klären, ob wir die Daten wirklich löschen wollen,
#    oder ob wir die Daten aus dem User Track löschen, als solche aber behalten
#
                t_id = int(''.join(map(str, trackId)))              # tuple to integer
                deleteFile(t_id)
                
            """
                # Das muss noch scharf geschaltet werden, sobald der Prozess aktiv ist, der diese DB- Records befüllt
                # Wie werden diese Felder überhaupt befüllt?
                # Wer macht das wann?
                #
                # Achtung: noch nicht getestet !!!
                #
                with connections['depth'].cursor() as cursor:
                    try:
                        del_Query = "DELETE FROM trackpoints_raw_8 WHERE datasetid =%s;"
                        cursor.execute(del_Query, (trackId))
                        connections['depth'].commit()

                        del_Query = "DELETE FROM trackpoints_raw_10 WHERE datasetid =%s;"
                        cursor.execute(del_Query, (trackId))
                        connections['depth'].commit()

                        del_Query = "DELETE FROM trackpoints_raw_12 WHERE datasetid =%s;"
                        cursor.execute(del_Query, (trackId))
                        connections['depth'].commit()

                        del_Query = "DELETE FROM trackpoints_raw_16 WHERE datasetid =%s;"
                        cursor.execute(del_Query, (trackId))
                        connections['depth'].commit()

                        del_Query = "DELETE FROM trackpoints_raw_filter_8 WHERE datasetid =%s;"
                        cursor.execute(del_Query, (trackId))
                        connections['depth'].commit()

                        del_Query = "DELETE FROM trackpoints_raw_filter_10 WHERE datasetid =%s;"
                        cursor.execute(del_Query, (trackId))
                        connections['depth'].commit()

                        del_Query = "DELETE FROM trackpoints_raw_filter_12 WHERE datasetid =%s;"
                        cursor.execute(del_Query, (trackId))
                        connections['depth'].commit()

                        del_Query = "DELETE FROM trackpoints_raw_filter_16 WHERE datasetid =%s;"
                        cursor.execute(del_Query, (trackId))
                        connections['depth'].commit()

                    except (Exception, psycopg2.DatabaseError) as error:
                        logging.debug(error)
        
                    finally:
                        if connections['depth'] is not None:
                            connections['depth'].close()
            """
        
        except (Exception, psycopg2.DatabaseError) as error:
            logging.debug(error)
        
        finally:
            if connections['osmapi'] is not None:
                connections['osmapi'].close()
        
            HttpResponse.status_code = 200
            return HttpResponse("OK")

def deleteFile(track_id):
    if track_id < 100:
        nr = '000'
    else:
        x = track_id // 100     # ganzzahlige Division
        nr = str(x) + '00'

    try:
        fileName = UPLOAD_PATH + nr + "/" + str(track_id) + ".dat"
        os.remove(fileName)
        
    except OSError as error:
        logging.debug(error)
        pass
        
    finally:
        return



