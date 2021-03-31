'''
Created on 14.02.2021

@author: Richard Kunzmann
'''

from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token
from django.contrib.auth import authenticate, login
from django.db import connections
import logging

logger = logging.getLogger(__name__)

@csrf_exempt
@requires_csrf_token
def changePassword(request):
    

    if request.method == 'POST':    
        if request.user.is_authenticated:                       # abprüfen der Identität, damit der User sein eigenes PW ändern darf
            
#        Das muss noch implementiert werden
#
#        "UPDATE AuthUser SET password = ? WHERE password = ? AND user_name = ?"        unverschlüsselt
#        falls wir mit zwei DB arbeiten wollen

            with connections['osmapi'].cursor() as cursor:
                pw_query = ("select password from user_profiles where user_name='{}'".format(request.user))
                cursor.execute(pw_query)
                old_pw = ''.join(cursor.fetchone())             # convertiere das (PW)-Ergebnis tupel in string
                logger.debug('Das alte Passwort lautet: {}'. format(old_pw))
                
                if old_pw == request.POST['oldPassword']:
                    logger.debug('Die PW sind gleich !')
                    pw_query = ("update user_profiles set password='{}' where user_name='{}';".format(request.POST['newPassword'], request.user))
                    cursor.execute(pw_query)
                    connections['osmapi'].commit()
                else:
                    logger.debug('Das alte Passwort ist nicht mit der Datenbank identisch')
                    HttpResponse.status_code = 409                      # 409 = conflict
                    return HttpResponse("nein")
                    
                # Hinweis:
                # das Frontend prüft die Passworter vorab formal ab

                logger.debug('change Password: new= {}, old= {}, user= {}'.format(request.POST['newPassword'], request.POST['oldPassword'], request.user))
                logger.debug('wow, Password has changed')
                HttpResponse.status_code = 200
                return HttpResponse("ok")
        
        else:
            logger.debug('Password not changed')                # dieser Fall dürfte eigentlich nicht vorkommen, da der User zuvor ja eingelogged ist
            HttpResponse.status_code = 409                      # 409 = conflict
            return HttpResponse("nein")
        
        