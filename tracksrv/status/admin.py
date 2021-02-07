from django.contrib import admin

# Register your models here.

from .models import ProcessingStatus

admin.site.register(ProcessingStatus)
