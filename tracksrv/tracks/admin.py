from django.contrib import admin

# Register your models here.

from .models import Track,ProcessingStatus

admin.site.register(Track)
admin.site.register(ProcessingStatus)
