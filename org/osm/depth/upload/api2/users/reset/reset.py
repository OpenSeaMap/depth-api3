'''
Created on 03.03.2021

@author: Richard Kunzmann
'''
from django.http import HttpResponse
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token
#from django.contrib.auth import authenticate
#from django.db import models
import psycopg2

import json


#------------------------------------------------
# main function 
#
@csrf_exempt
@requires_csrf_token
def reset_password(request):

# hier muss noch eingefügt werden
#
# 1. Prüfen des User in der DB
# 2. neues PW generieren und in die DB eintragen
    newPW = get_newPW_string(24)                                                 # string of length 8
    print(newPW)

# 3. neues PW per Mail an user senden


    data = request.body.decode('ascii') 
#    print(data)   
    str1 = data.split('=',2)
    str2 = str1[1].split('&')
    str3 = str2[0].replace('%40','@')
    
#    print('Function body: ',str1, str2, str2[0], str3)
    to_user = str3
    send_mail(to_user, newPW)
    
    return HttpResponse('ok')

#------------------------------------------------
# send eMail to user containing the new password
#
import smtplib, ssl
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_mail(to_user, newPW):
    port = 465                                                  # For SSL   / RKu: 587
    smtp_server = "t.b.d"
    sender_email = "t.b.d"                     # Enter your address /muss drinend geändert werden
    receiver_email = str(to_user)                               # Enter receiver address
    password = "t.b.d"                                       # input("Type your password and press enter: ")

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
    
    message.attach(MIMEText(message_text1, "plain", _charset = 'utf-8'))
    
    context = ssl.create_default_context()
    with smtplib.SMTP_SSL(smtp_server, port, context=context) as server:
        server.login(sender_email, password)
        server.sendmail(sender_email, receiver_email, message.as_string())
        

#------------------------------------------------
# generate a character string with upper and lowercase characters
#        
import random
import string

def get_newPW_string(length):
    # With combination of lower and upper case
    newPW_str = ''.join(random.choice(string.ascii_letters) for i in range(length))
    return newPW_str




        