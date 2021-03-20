'''
Created on 05.02.2021

@author: Richard Kunzmann
'''

from django.http import HttpResponse

# nur ein schneller Test, ob der Server reagiert
# 
def dummy(request):
    HttpResponse.status_code = 200
    return HttpResponse("ok")
