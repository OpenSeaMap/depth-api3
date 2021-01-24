from django.urls import path

from . import views

app_name = 'tracks'
urlpatterns = [
    path('', views.index, name='api-tracks-index'),
    path('<int:track_id>', views.detail, name='api-tracks-detail'),
    path('<int:track_id>/raw', views.raw, name='api-tracks-raw'),
]
