from django.urls import path

from . import views

app_name = 'tracks'
urlpatterns = [
    path('', views.index, name='index'),
    path('<int:track_id>', views.detail, name='detail'),
    path('<int:track_id>/raw', views.raw, name='download raw track file'),
]
