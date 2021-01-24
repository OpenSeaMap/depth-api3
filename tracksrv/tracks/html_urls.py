from django.urls import path

from . import views

app_name = 'tracks'
urlpatterns = [
    path('', views.html_index, name='html_index'),
#    path('<int:track_id>', views.detail, name='html_detail'),
#    path('<int:track_id>/raw', views.raw, name='download raw track file'),
#    path('',,name=''),
]
