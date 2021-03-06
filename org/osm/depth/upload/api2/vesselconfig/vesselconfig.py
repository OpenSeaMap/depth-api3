'''
Created on 12.02.2021

@author: Richard Kunzmann
'''

from django.http import HttpResponse
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token


import psycopg2
from psycopg2.extras import DateTimeRange
import json


#
# Dispatcher I
#
@csrf_exempt
@requires_csrf_token
def VesselConfig(request):
    
    if request.method == 'GET':
        print('Methode "GET" die ID lautet: ',  request.GET)
        return getVesselConfig(request)
        
#    if request.method == 'POST':
#        print('Methode "POST" die ID lautet: ', request.POST.get('id'))
#        cur_id = request.POST.get('id', None)
#        if cur_id == None:
#            return (createVesselConfigWithNullId(request))
        
#    if request.method == 'PUT':
#        print('Methode "PUT" die ID lautet:', request.PUT)
#        return JsonResponse("Put ok")

#@csrf_exempt
#@requires_csrf_token
#def vessel_mit_id(request,del_id):
#    if request.method == 'DELETE':
#        return (deleteVesselConfig(request,del_id))
#    elif request.method == 'POST':
#        print('Methode "POST" mit ID "null": ')
#        if null == 'null':
#        return (createVesselConfigWithNullId(request))
#    else:
#        return HttpResponse(status=[403])

#
# Dispacher II
#
# Sonderbehandlung mit speziellen path Parametern
# Der Parameter "null" kann sein, das literal 'null' oder eine integer Zahl, die die Vesselnummer repräsentiert
#    
@csrf_exempt
@requires_csrf_token
def vessel_mit_null(request,null):
    print('mit_null %s ' % null)
    
    if request.method == 'DELETE':
        print('Methode "DELETE" mit ID : ', int(null))
        return (deleteVesselConfig(request,int(null)))              # 'null' enthält in diesem Fall die Vessel_id -> daher integer

    elif request.method == 'POST':
        print('Methode "POST" mit ID "null": ')
        return (createVesselConfigWithNullId(request))

    elif request.method == 'PUT':
        print('Methode "PUT" die ID lautet:', int(null))
#        return JsonResponse("PUT ok", safe=False)
        return (updateVesselConfig(request,int(null)))              # 'null' enthält in diesem Fall die Vessel_id -> daher integer

    else:
        return HttpResponse(status=[404])
   
    
def getVesselConfig(request):   
    vessel = {}
    vessels = [{}]

    newsbasoffset = {}
    newdepthoffset = {}

    conn = None
    try:
        conn = psycopg2.connect(user="postgres",
                                password="osm",
                                host="127.0.0.1",
                                port="5432",
                                database="osmapi")
        cur = conn.cursor()

        if request.user.is_authenticated:
            xx = "{}".format(request.user)                                  # get current user name of the requestor
            postgreSQL_select_Query = ("SELECT DISTINCT    v.id, v.name, v.description, v.loa, v.breadth, v.draft, v.height, v.displacement, v.mmsi, v.manufacturer, v.model, v.maximumspeed, v.type, s.x, s.y, s.z, s.manufacturer, s.model, s.sensorid, d.x, d.y, d.z, d.manufacturer, d.model, d.sensorid, d.frequency, d.offsetkeel, d.offsettype FROM vesselconfiguration v LEFT JOIN depthsensor AS d ON (d.vesselconfigid = v.id) LEFT JOIN sbassensor AS s ON (s.vesselconfigid = v.id) WHERE user_name='%s' ;" %xx )
#                                                      0     1       2              3      4          5        6         7               8       9               10       11              12      13   14   15   16              17       18          19   20   21   22              23       24          25           26            27
            cur.execute(str(postgreSQL_select_Query))
            db_vessel = cur.fetchone()

            i = 0            
            while db_vessel is not None:
                print('vesselconfig - updateVesselConfig: ', db_vessel)
        
                newsbasoffset['distanceFromStern']  = db_vessel[14]
                newsbasoffset['distanceFromCenter'] = db_vessel[13]
                newsbasoffset['distanceWaterline']  = db_vessel[15]
                newsbasoffset['sensorid']           = db_vessel[18]
                newsbasoffset['manufacturer']       = db_vessel[16]
                newsbasoffset['model']              = db_vessel[17]
   
                newdepthoffset['distanceFromStern'] = db_vessel[20]
                newdepthoffset['distanceFromCenter']= db_vessel[19]
                newdepthoffset['distanceWaterline'] = db_vessel[21]
                newdepthoffset['offsetKeel']        = db_vessel[26]
                newdepthoffset['offsetType']        = db_vessel[27]
                newdepthoffset['manufacturer']      = db_vessel[22]
                newdepthoffset['model']             = db_vessel[23]
        
                vessel['id']            = db_vessel[0]
                vessel['name']          = db_vessel[1]
                vessel['description']   = db_vessel[2]
                vessel['manufacturer']  = db_vessel[9]
                vessel['model']         = db_vessel[10]
                vessel['mmsi']          = db_vessel[8]
                vessel['loa']           = db_vessel[3]
                vessel['breadth']       = db_vessel[4]
                vessel['draft']         = db_vessel[5]
                vessel['height']        = db_vessel[6]
                vessel['displacement']  = db_vessel[7]
                vessel['maximumspeed']  = db_vessel[11]
                vessel['vesselType']    = db_vessel[12]
                vessel['sbasoffset']    = dict(newsbasoffset)
                vessel['depthoffset']   = dict(newdepthoffset)

#                vessels[i] = dict(vessel)                   # das ist es. hey das hat mich Nerven gekostet
                vessels.insert(i, dict(vessel))        # das geht auch

                print('vessels[i]: bei ',i ,' = ', vessels[i])
                i += 1
                db_vessel = cur.fetchone()
                
            vessels.pop()
            print(vessels)
        else:
            print('vesselconfig - updateVesselConfig: no data')
            
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        
    finally:
        if conn is not None:
            conn.close()
    
    return JsonResponse(vessels, safe=False)

#    HttpResponse.status_code = 200
#    return HttpResponse("ok")


@csrf_exempt
@requires_csrf_token
def createVesselConfigWithNullId(request):
    print('vesselconfig - createVesselConfigWithNullId: ')

    try:
        conn = psycopg2.connect(user="postgres",
                                password="osm",
                                host="127.0.0.1",
                                port="5432",
                                database="osmapi")
        cur = conn.cursor()

        if request.user.is_authenticated:
            print('User = ', request.user)


            vessel_data = json.loads(request.body)
            sbas = vessel_data['sbasoffset']
            depth = vessel_data['depthoffset']
            
            print('Vessel Data  : ', vessel_data)
            print('sbas offsets : ', sbas)
            print('dept offsets : ', depth)

            vessel_type = '1'                           # wird nicht vom Frontend übergeben
            vessel_data['maximumspeed'] = '7.5'         # wird nicht vom Frontend übergeben

            new_vessel_sql = """INSERT INTO vesselconfiguration (name, description, mmsi, manufacturer, model, loa, breadth, draft, height, displacement, maximumspeed, type, user_name) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s) RETURNING id;"""
            cur.execute(new_vessel_sql, (str(vessel_data['name']), str(vessel_data['description']), "None", vessel_data['manufacturer'], vessel_data['model'], vessel_data['loa'], vessel_data['breadth'], vessel_data['draft'], vessel_data['height'], vessel_data['displacement'], vessel_data['maximumspeed'], vessel_type, str(request.user)))
            return_id = cur.fetchone()[0]               # get the generated id back
            conn.commit()                               # Wichtig: commit the changes to the database

            new_vessel_dos = "INSERT INTO depthsensor (vesselconfigid, x, y, z, offsetkeel, manufacturer, model, offsettype, sensorid, frequency, angleofbeam) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s);"
            cur.execute(new_vessel_dos, (return_id, depth['distanceFromStern'], depth['distanceFromCenter'], depth['distanceWaterline'], depth['offsetKeel'], depth['manufacturer'], depth['model'], depth['offsetType'], 'nn', '0', '0'))    
            conn.commit()                               # Wichtig: commit the changes to the database
            
            sbas['sensorid'] = 'nn'                     # sensorid nicht vom Frontend übergeben -> daher 'nn'
            new_vessel_sos = "INSERT INTO sbassensor (vesselconfigid, x, y, z, sensorid, manufacturer, model) VALUES (%s,%s,%s,%s,%s,%s,%s);"
            cur.execute(new_vessel_sos, (return_id, sbas['distanceFromStern'], sbas['distanceFromCenter'], sbas['distanceWaterline'], sbas['sensorid'], sbas['manufacturer'], sbas['model']))
            conn.commit()                               # Wichtig: commit the changes to the database

    
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        
    finally:
        if conn is not None:
            conn.close()
    
    return HttpResponse("OK")
#    return JsonResponse(return_id, safe=False)          # noch unklar ob es hier Sinn mancht die ID zurück zu geben.


@csrf_exempt
@requires_csrf_token
def updateVesselConfig(request, vessel_id):
    
    print('vesselconfig - createVesselConfig: ')
    
#    print('Vessel_Id =: ', vessel_id, 'Raw Data: "%s"' % request.body)

    try:
        conn = psycopg2.connect(user="postgres",
                                password="osm",
                                host="127.0.0.1",
                                port="5432",
                                database="osmapi")
        cur = conn.cursor()
    
        vessel_data = json.loads(request.body)
        sbas = vessel_data['sbasoffset']
        depth = vessel_data['depthoffset']

        print('Vessel Data  : ', vessel_data)
        print('sbas offsets : ', sbas)    
        print('dept offsets : ', depth)    
    
        vessel_data['vesselType'] = '1'             # nur eine dummy Angabe -- hier gibt das Frontend falsche Daten
        vessel_data['maximumspeed'] = '7.5'         # nur eine dummy Angabe -- hier gibt das Frontend keine Daten

        new_vessel_sql = """UPDATE vesselconfiguration set name=%s, description=%s, mmsi=%s, manufacturer=%s, model=%s, loa=%s, breadth=%s, draft=%s, height=%s, displacement=%s, maximumspeed=%s, type=%s where id=%s;"""
        cur.execute(new_vessel_sql,(str(vessel_data['name']), str(vessel_data['description']), "None", vessel_data['manufacturer'], vessel_data['model'], vessel_data['loa'], vessel_data['breadth'], vessel_data['draft'], vessel_data['height'], vessel_data['displacement'], vessel_data['maximumspeed'], vessel_data['vesselType'], vessel_id))
        conn.commit()                               # Wichtig: commit the changes to the database

        new_vessel_dos = "UPDATE depthsensor set x=%s, y=%s, z=%s, offsetkeel=%s, manufacturer=%s, model=%s, offsettype=%s where vesselconfigid=%s;"
        cur.execute(new_vessel_dos, (depth['distanceFromStern'], depth['distanceFromCenter'], depth['distanceWaterline'], depth['offsetKeel'], depth['manufacturer'], depth['model'], depth['offsetType'], vessel_id))    
        conn.commit()                               # Wichtig: commit the changes to the database

        sbas['sensorid'] = 'nn'                     # sensorid nicht vom Frontend übergeben -> daher 'nn'
        new_vessel_sos = "UPDATE sbassensor set x=%s, y=%s, z=%s, sensorid=%s, manufacturer=%s, model=%s where vesselconfigid=%s;"
        cur.execute(new_vessel_sos, (sbas['distanceFromStern'], sbas['distanceFromCenter'], sbas['distanceWaterline'], sbas['sensorid'], sbas['manufacturer'], sbas['model'], vessel_id))
        conn.commit()                               # Wichtig: commit the changes to the database

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        
    finally:
        if conn is not None:
            conn.close()
    
        return JsonResponse("ok", safe=False)


@csrf_exempt
@requires_csrf_token
def getAll(request):

    try:
        conn = psycopg2.connect(user="postgres",
                                password="osm",
                                host="127.0.0.1",
                                port="5432",
                                database="osmapi")
        cur = conn.cursor()

        postgreSQL_select_Query = ("SELECT DISTINCT    v.id, v.name, v.description, v.loa, v.breadth, v.draft, v.height, v.displacement, v.mmsi, v.manufacturer, v.model, v.maximumspeed, v.type, s.x, s.y, s.z, s.manufacturer, s.model, s.sensorid, d.x, d.y, d.z, d.manufacturer, d.model, d.sensorid, d.frequency, d.offsetkeel, d.offsettype FROM vesselconfiguration v LEFT JOIN depthsensor AS d ON (d.vesselconfigid = v.id) LEFT JOIN sbassensor AS s ON (s.vesselconfigid = v.id) WHERE user_name='Richard.Kunzmann@t-online.de';")
        cur.execute(str(postgreSQL_select_Query))
        db_user = cur.fetchone()
        print('vesselconfig - getAll: ')

    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        
    finally:
        if conn is not None:
            conn.close()
    
    return JsonResponse(db_user)
#    return JsonResponse("ok", safe=False)    
    


@csrf_exempt
@requires_csrf_token
def deleteVesselConfig(request,del_id):
#    print('vesselconfig - deleteVesselConfig: ', del_id)
    
    try:
        conn = psycopg2.connect(user="postgres",
                                password="osm",
                                host="127.0.0.1",
                                port="5432",
                                database="osmapi")
        cur = conn.cursor()    
    
        del_vessel_sql = "DELETE from vesselconfiguration where id=%s RETURNING id;"
        cur.execute(del_vessel_sql, (del_id,))

        return_id = cur.fetchone()[0]               # get the generated id back
        conn.commit()                               # Wichtig: commit the changes to the database
#        print('Der Record ', return_id, 'wurde gelöscht')
    
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
        
    finally:
        if conn is not None:
            conn.close()
    
    return HttpResponse("ok")

