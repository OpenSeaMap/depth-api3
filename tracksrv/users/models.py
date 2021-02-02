from datetime import timedelta
from django.utils import timezone
from django.contrib.gis.db import models
from django.utils.translation import gettext_lazy as _
from django.contrib.auth.models import User
from languages.fields import LanguageField, RegionField

class DepthUser(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        primary_key=True,
    )
    created_on = models.DateField('date this user was registered in the database', default=timezone.now)
    may_contact = models.BooleanField('has the user agreed to be contacted by email', default=True)
    last_attempt = models.DateTimeField('last time this user attempted or successfully logged in', null=True)
    region = RegionField('region setting to regionalize any units, or cartographic conventions')
    language = LanguageField('UI language for the user',max_length=8)
    organization = models.CharField('organization that the user represents', max_length=32,blank=True)

    def __str__(self):

        if (timezone.now() - self.last_attempt) >= timedelta(days=366):
            act = "(inactive)"
        else:
            act = ""
        return "{} {} {}".format(self.user.first_name, self.user.last_name,act)
