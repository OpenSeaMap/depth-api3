"""depth3 URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))

Created on 06.02.2021

@author: Richard Kunzmann
"""
from django.urls import path
#from django.conf.urls import *
from . import vesselconfig


urlpatterns = [
    path('', vesselconfig.VesselConfig, name ='VesselConfig'),
    path('/<str:null>', vesselconfig.vessel_mit_null, name='vessel_mit_null'),
#    path('<int:del_id>', vesselconfig.vessel_mit_id, name='vessel_mit_id'),
    
#    url('(?P<null>)?$', vesselconfig.vessel_mit_null),
#    url('(?P<del_id>[0-9]+)?$', vesselconfig.vessel_mit_id),
]

