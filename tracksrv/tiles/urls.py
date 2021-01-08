from django.urls import path

from . import views

app_name = 'tiles'
urlpatterns = [
#    path('', views.index, name='index'),
    path('contour/<int:z>/<int:x>/<int:y>', views.contour, name='contour tile'),
#    path('<int:track_id>/raw', views.raw, name='download raw track file'),
]
