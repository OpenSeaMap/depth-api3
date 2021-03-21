'''
Created on 06.02.2021

@author: richard
'''

from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token
from django.contrib.auth import authenticate, login
import logging


def check(request):
    logger = logging.getLogger(__name__)
    c_user = authenticate(username=request.POST['j_username'], password=request.POST['j_password'])
    if c_user is not None:
        login(request, c_user)
        logger.debug('wow, Du bist eingelogged')
        HttpResponse.status_code = 200
        return HttpResponse('ok')
    else:
        logger.debug('login fehlgeschlagen')
        HttpResponse.status_code = 403
        return HttpResponse('login failed')
