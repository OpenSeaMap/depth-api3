'''
Created on 03.03.2021

@author: Richard Kunzmann
'''
from django.http import HttpResponse
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token
from django.db import connections
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from django.core.mail import send_mail
from org import _queryhelper, userdb_columns

import json
import environ
import logging
import hashlib
import random
import string


logger = logging.getLogger(__name__)
global captcha_rk

#------------------------------------------------
# main function 
#
@csrf_exempt
@requires_csrf_token
def reset_password(request):

    
# 1. Prüfen ob der User überhaupt schon in der DB angelegt ist
#
    with connections['osmapi'].cursor() as cursor:
        test_Query = ("select * from user_profiles where user_name=%s;")
        cursor.execute(test_Query, ("{}".format(request.POST['username']),))
        db_record = cursor.fetchone()
        if (db_record[0] != request.POST['username']):
            HttpResponse.status_code = 404                      # 404 = not found
            return HttpResponse('nein')
        
        # Stimmt das gesendete captcha mit dem eingegebenen überein?
        if (request.POST['captcha'] != request.session['captcha_rk']):
            HttpResponse.status_code = 401                      # 401 = captcha falsch: Unauthorized access
            return HttpResponse('nein')
        
# 2. neues PW generieren
#
    newPW = get_newPW_string(24)  # string of length 8
    logger.debug('Das neue Password lautet: {}'.format(newPW))
    
    bytePW = newPW.encode('utf-8')          # umwandeln in unicode byte string
    hashPW = hashlib.sha1(bytePW)           # hash generieren
#    jQuery.encoding.digests.hexSha1Str(params.neuPassword1).toLowerCase()
    newPWSha1 = hashPW.hexdigest()          # hash in hex Digits umwandeln für das speichern in der DB

# 3. neues PW in die 'osmapi' DB eintragen
#
    with connections['osmapi'].cursor() as cursor:
        update = ("update user_profiles set password='{}' where user_name='{}';".format(newPWSha1, request.POST['username']))
        cursor.execute(update)
        connections['osmapi'].commit()                        # noch nicht in die DB schreiben ... erst wenn der Rest geht

# 4. neues PW per Mail an user senden
#
    to_user = request.POST['username']
    send_reset_mail(to_user, newPW)                             # send Mail to user
    HttpResponse.status_code = 200
    return HttpResponse('ok')

#------------------------------------------------
# send eMail to user containing the new password
#

def send_reset_mail(to_user, newPW):
    
    env = environ.Env()
    environ.Env.read_env()                      # reading .env file
    sender_email = env.str('EMAIL_HOST_USER')   # Enter your address
    receiver_email = str(to_user)               # Enter receiver address

    message = MIMEMultipart("alternative")
    message["Subject"] = "your OpenSeaMap - dept - password reset"
    message["From"] = sender_email
    message["To"] = receiver_email
    message_text1 = """\
    Hello Seaman

    Your new password has been set to :  {} 
    
    Please make sure, you change this password to whatever you like after your first login !!!
    
    With best regards
    Your OpenSeaMap Team
    """.format(newPW)
    
#    message.attach(MIMEText(message_text1, "plain", _charset='utf-8'))
    send_mail(message["Subject"], message_text1, message["From"], [message["To"]])


#------------------------------------------------
# generate a character string with upper and lowercase characters
#        

def get_newPW_string(length):
    # With combination of lower and upper case
    newPW_str = ''.join(random.choice(string.ascii_letters) for i in range(length))
    return newPW_str

        
