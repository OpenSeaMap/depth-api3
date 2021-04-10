'''
Created on 01.03.2021

@author: Richard Kunzmann
'''
import json
import logging
import requests
import base64

from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token
from captcha.models import CaptchaStore
from captcha.helpers import captcha_image_url


logger = logging.getLogger(__name__)

@csrf_exempt
@requires_csrf_token
def view_captcha(request):

    to_json_response = dict()
    to_json_response['status'] = 1

    to_json_response['new_cptch_key'] = CaptchaStore.generate_key()
    to_json_response['new_cptch_image'] = captcha_image_url(to_json_response['new_cptch_key'])

    # save a persistent copy of the captcha key for later verification (at function "reset")
    response = CaptchaStore.objects.get(hashkey=to_json_response['new_cptch_key']).response.upper()
    request.session['captcha_rk'] = response    

    logger.debug("Captcha key {}".format(to_json_response['new_cptch_key']))
    logger.debug("Captcha image url {}".format(to_json_response['new_cptch_image']))

    # download captcha file and convert it to base64 string
    domain = request.get_host()
    address = "http://" + domain + to_json_response['new_cptch_image']
    file = requests.get(address, stream=True)
    capt = base64.b64encode(file.raw.data).decode('utf-8')

    c_response = dict()
    c_response['status'] = 1
    c_response['imageBase64'] = capt

    logger.debug(c_response)
    HttpResponse.status_code = 200
    return HttpResponse(json.dumps(c_response), content_type='application/json')


