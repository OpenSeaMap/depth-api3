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

from rest_framework import routers
from tracks import views as trackviews
from vessels import views as vesselviews
from licenses import views as licenseviews
from users import views as userviews

import debug_toolbar

router = routers.DefaultRouter()
router.register(r'tracks', trackviews.TrackViewSet)
router.register(r'vessels', vesselviews.VesselViewSet)
router.register(r'licenses', licenseviews.LicenseViewSet)
router.register(r'users', userviews.UserViewSet)
router.register(r'authusers', userviews.AuthUserViewSet)


urlpatterns = [
    path('', include(router.urls)),
    path('api-auth/', include('rest_framework.urls', namespace='rest_framework')),
#    path('mytracks/', TrackListView.as_view(), name='my-tracks'),
#    path('tracks/<int:pk>', TrackDetailView.as_view()),
#    path('vessels/<int:pk>', VesselDetailView.as_view()),# needs to change
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
