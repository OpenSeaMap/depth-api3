from django.utils import timezone
from django.contrib.gis.db import models
from django.utils.translation import gettext_lazy as _

class License(models.Model):
  """
  a register of possible open data licenses for use in the depth project
  """
  name = models.CharField(max_length=128, blank=False, null=False)
  version = models.CharField(max_length=32, blank=True)
  visited_on = models.DateField(null=False,default=timezone.now)
  url  = models.URLField('link to the license', null=True)
  copy = models.TextField('a copy of the license, in case the original license goes away')

  def __str__(self):
    return '{} (see {})'.format(self.name, self.url)
