from django.urls import path

from . import views

app_name = 'tiles'
urlpatterns = [
#    path('', views.index, name='index'),
    path('contour/<int:z>/<int:xi>/<int:yi>', views.contour, name='contour tile'),
#    path('<int:track_id>/raw', views.raw, name='download raw track file'),
    path('debug/track/<int:z>/<int:xi>/<int:yi>',views.track, name='track points'),
    path('debug/delaunay/<int:z>/<int:xi>/<int:yi>',views.delaunay, name='track delaunay diagram'),
]
