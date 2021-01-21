from django.contrib import admin

# Register your models here.

from .models import Track,Vessel

admin.site.register(Track)
admin.site.register(Vessel)
