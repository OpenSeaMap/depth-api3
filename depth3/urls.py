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
"""
from django.contrib import admin
from django.urls import include, path
from org.index import index

urlpatterns = [
    path('', index),
    path('admin/', admin.site.urls),
    path('api-auth/', include('rest_framework.urls')),
    path('org.osm.depth.upload/api2/auth', include('org.osm.depth.upload.api2.auth.urls')),
    path('org.osm.depth.upload/api2/auth',  include('org.osm.depth.upload.api2.auth.urls')),
    path('org.osm.depth.upload/api2/auth/logout', include('org.osm.depth.upload.api2.auth.logout.urls')),
    path('org.osm.depth.upload/api2/j_security_check', include('org.osm.depth.upload.api2.j_security_check.urls')),
    path('org.osm.depth.upload/api2/license', include('org.osm.depth.upload.api2.license.urls')),
    path('org.osm.depth.upload/api2/gauge', include('org.osm.depth.upload.api2.gauge.urls')),
    path('org.osm.depth.upload/api2/track', include('org.osm.depth.upload.api2.track.urls')),
    path('org.osm.depth.upload/api2/users', include('org.osm.depth.upload.api2.users.urls')),
    path('org.osm.depth.upload/api2/users/current', include('org.osm.depth.upload.api2.users.current.urls')),
    path('org.osm.depth.upload/api2/users/changepass', include('org.osm.depth.upload.api2.users.changepass.urls')),
    path('org.osm.depth.upload/api2/users/update', include('org.osm.depth.upload.api2.users.update.urls')),
    path('org.osm.depth.upload/api2/users/captcha', include('org.osm.depth.upload.api2.users.captcha.urls')),
    path('org.osm.depth.upload/api2/users/captcha', include('captcha.urls')),
    path('org.osm.depth.upload/api2/users/reset', include('org.osm.depth.upload.api2.users.reset.urls')),
    path('org.osm.depth.upload/api2/vesselconfig', include('org.osm.depth.upload.api2.vesselconfig.urls')),
#    path('org.osm.depth.upload/api2/vesselconfig/null', include('org.osm.depth.upload.api2.vesselconfig.urls')),
#    path('static/', singletrack.html),
]
