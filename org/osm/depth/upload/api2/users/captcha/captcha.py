'''
Created on 01.03.2021

@author: Richard Kunzmann
'''
import json
import logging
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt, requires_csrf_token
from captcha.models import CaptchaStore
from captcha.helpers import captcha_image_url

logger = logging.getLogger(__name__)

# todo: use the django captcha method
#       web frontend needs to load and show the image given by "Captcha image url" in the response
#       sample url: http://localhost:8003/org.osm.depth.upload/api2/users/captchaimage/c873aff95238f4d26c95bcc5053f285ddf615cdc/

@csrf_exempt
@requires_csrf_token
def sample_view_captcha(request):
    to_json_response = dict()
    to_json_response['status'] = 1

    to_json_response['new_cptch_key'] = CaptchaStore.generate_key()
    to_json_response['new_cptch_image'] = captcha_image_url(to_json_response['new_cptch_key'])

    logger.debug("Captcha key {}".format(to_json_response['new_cptch_key']))
    logger.debug("Captcha image url{}".format(to_json_response['new_cptch_image'] ))

    return HttpResponse(json.dumps(to_json_response),
                        content_type='application/json')

@csrf_exempt
@requires_csrf_token
def view_captcha(request):
    capt = "iVBORw0KGgoAAAANSUhEUgAAAKAAAAAoCAYAAAB5LPGYAAAEzElEQVR42u1afWiWVRS/ztJ0aUYu\nP2pqmIktY7I/NEQNgpz4EdJssn8kiCVmTZeFUKGGKIp/KKgIqZRjIgwUBU20YE1LFD9YUTZQxLJp\nOS2oTas1OxfPC5ez5577fL173r3P+cEPxvucc9773vvbfc459yolEAgEAoFAIBAIBIJQuMdQxiuQ\nBRUBigBlvAJZUBGgCFDGKxAB5pEAhwNXAb8EtgE7gX8AvwVuAj4rApTxZgMDgduBfzt+z39o95AI\nUKlhwPeBp4DXcfJagceBNTipYRA0bm8X4AjgGcfvoPw6wvzmhQDfBXY4bH8BTsmRuF5Y5/A9yzxr\nB05wxC9x/JadaPcz+bwZWA18GjgAWAx8GVhH7D5LowAL8If7/U/9C/h8gnFt+Jjx6cKdVr/mLjB2\nWij9LfG1cL5jfM8br1Hz83ompsZLmBdm7F9ImwC3BnxVaJ5LMK4XVjtyrDcM27FYBNjst1i+Ywfj\ncxv4lGW+n/CxPub4P0mbAMPyxYTiUnzI2P4LrPLweQV3RZvfbGL/qmN3nUPs2wwW+lifiUa8S7ks\nkjC2fu0/BZbia2Q0cHNMO1zccU2sZOx0oTOfme8NjO9v2D5ROObfGdu1Maz9ACPenTQKcI1lTLsZ\nn9MJxc3gPcZGFwozHfPdF9jIxDgGfBCrU5vNccx1o2KcEfNq2gT4Ay6GF2YwfjcSiquxnHn+J8b3\n2x5qdRQWtme60i2Kae3NNOJIUgIsR75FqiLN9fjMtG0gNjrfqDTi+BVgLTOmkYzf3YTivsM806/K\nyQHnfRrmikHy1H9I2ygKnsEWkJ956zFUEBG2k//qRR67xnMhd9cyxq8wQjGRrbhc3lYacr5XBPyu\npTGt85PAK0bcy46WTY/iNYsIK7G1kPn8J8whwr7ehzB+D0QQRLbi2hrZEyLO936f37U3pvUtIQ3r\nLo/qO3EsJGLrIKLU/zFjIuaXfRm/PhFEka24tsJlUMS5HuzIBzNCL4xhXad7VNaLc7WHV0VEmOFF\nzKWiFjjZ6iH2dG+ySUU7S53p6A1mODfiei5Q3S8orMj1RvJaj0R9VEwVdm8TYCfz7AsV7laJ7vn9\n6vP72zB3C4MaInL997JcF58+H/U6OtL3yx5OoQBfd+xUnwP7BZjfAhRukDF85UgxvL5jo8cmUpHr\n4tPnlteZifjGkeznowAVtio4m4PYRPaDD0KOY3WAU459xPcWcCqxKzWYExiBRYY5cH2ovsGjWVqU\nMgF6pSWUDT52qalMD1DvUNXM804fDW+do9N7gfqsd7xjPhKH3tWayaDeNLZzeo/se0dBko8C1Njm\nsK1X9qOyR9X9Yy+bbw3afcTYXAM+Zolfhs9N+xPAoT7mI1HoSu4kGdASYqNznGPEhmvJ5KsA+6DI\nOPvdaEdxgPE5avgUYIVtsz1kqXTpxdU6R5M5UQGWGzxMBnNAdT9aK8cfSYsT3dicr7ofx+WrABXm\neocdPjuIz9uM7U1Mf0wUK/5GTI1hW2spWmaRdaZMVIDZuF51LyUCzCT6TQ6/LUayz503z2P6d9zV\nr0lo1xhDT1ME2MsEqPGI4m+vaOq7iC0BdkqKXYxvC7bFRIApFaDG4w6BcfzRx0lKoSP+nt4qQIFA\nIBAIBAKBQCBQ/wNmYxbV3vznegAAAABJRU5ErkJggg==",
    c_response = dict()
    c_response['status'] = 1
    c_response['imageBase64'] = capt
    logger.debug(c_response)
    return HttpResponse(json.dumps(c_response), content_type='application/json')
