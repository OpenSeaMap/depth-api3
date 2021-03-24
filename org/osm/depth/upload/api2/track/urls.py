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
from . import track

urlpatterns = [
    path('', track.getTrack, name ='getTrack'),
    path('/<str:null>', track.deleteTrack, name='deleteTrack'),
]
