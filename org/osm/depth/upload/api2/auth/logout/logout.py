'''
Created on 06.02.2021

@author: richard
'''

from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token
from django.contrib.auth import logout

@csrf_exempt
@requires_csrf_token
def logoutUser(request):
    logout(request)
    return HttpResponse("ok")
    
#    if request.method == "POST" and request.is_ajax():
#        HttpResponse.status_code = 200
#        return HttpResponse("ok")
#    else:
#        HttpResponse.status_code = 400 
#        return HttpResponse("false") 