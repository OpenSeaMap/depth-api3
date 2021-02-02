"""tracksrv URL Configuration

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
"""
from django.contrib import admin
from django.urls import include,path

import debug_toolbar
from tracks.views import TrackListView,TrackDetailView
from vessels.views import VesselDetailView

urlpatterns = [
    path('mytracks/', TrackListView.as_view(), name='my-tracks'),
    path('tracks/<int:pk>', TrackDetailView.as_view()),
    path('vessels/<int:pk>', VesselDetailView.as_view()),# needs to change
    path('1.0/tiles/', include('tiles.urls')),
    path('admin/', admin.site.urls),
]

#Add Django site authentication urls (for login, logout, password management)

urlpatterns += [
    path('accounts/', include('django.contrib.auth.urls')),
]

# add SQL DEBUG toolbar
urlpatterns += [
    path('__debug__/', include(debug_toolbar.urls)),
]