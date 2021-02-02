from django.contrib import admin

# Register your models here.

from .models import Track,Vessel,DepthUser,ProcessingStatus

admin.site.register(Track)
admin.site.register(Vessel)
admin.site.register(DepthUser)
admin.site.register(ProcessingStatus)
