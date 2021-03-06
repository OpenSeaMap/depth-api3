'''
Created on 14.02.2021

@author: Richard Kunzmann
'''

from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token

from django.contrib.auth import authenticate, login

@csrf_exempt
@requires_csrf_token
def changePassword(request):

    if request.method == 'POST':    
        if request.user.is_authenticated:
#        "UPDATE user_profiles SET password = ? WHERE password = ? AND user_name = ?"    verschlüsselt
#        1 = newPassword, 2 = oldPassword, 3 = username
#        bzw.
#        "UPDATE AuthUser SET password = ? WHERE password = ? AND user_name = ?"        unverschlüsselt
            print('change Password: ', request.POST['newPassword'],request.POST['oldPassword'], request.user)
            print('wow, Password has changed')
            return HttpResponse("ok")
        else:
            print('Password not changed')
            return HttpResponse("nein")
        
        