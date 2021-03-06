'''
Created on 06.02.2021

@author: richard
'''

from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token

from django.contrib.auth import authenticate, login

@csrf_exempt
@requires_csrf_token
def check(request):
    print('j_security_check: ', request.POST['j_username'], '  ', request.POST['j_password'], '   ', request.COOKIES)
    c_user = authenticate(username=request.POST['j_username'], password=request.POST['j_password'])
    
    if c_user is not None:
        login(request, c_user)
        print('wow, Du bist eingelogged')
        return HttpResponse("ok")
    else:
        print('login fehlgeschlagen')
        return HttpResponse("nein")
    
#    if request.method == "POST" and request.is_ajax():
#        HttpResponse.status_code = 200
#        return HttpResponse("ok")
#    else:
#        HttpResponse.status_code = 400 
#        return HttpResponse("false") 