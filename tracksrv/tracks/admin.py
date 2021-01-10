from django.contrib import admin

# Register your models here.

from .models import Track,Vessel,User

admin.site.register(Track)
admin.site.register(Vessel)
admin.site.register(User)
