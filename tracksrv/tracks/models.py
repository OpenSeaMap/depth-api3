from datetime import timedelta,datetime
from django.utils import timezone
from django.contrib.gis.db import models
from django.utils.translation import gettext_lazy as _
from django.contrib.auth.models import User
from vessels.models import Vessel
from licenses.models import License
from .indexmanager import IndexManagerMixin

class Track(models.Model):
    class ProcessingStatus(models.TextChoices):
        NEW = 'NEW', _('New')
        FORMAT_IDENTIFIED = 'FID', _('Format identified')
        INGESTING = 'ING', _('Ingesting')
        DONE = 'DNE', _('Done')

    class FileFormat(models.TextChoices):
        GPX = 'GPX'
        NMEA0183 = '183', _('NMEA 0183')
        NMEA0183_OSM = 'OSM', _('NMEA 0183 with OSM timestamps')
        TAGGED_CSV = 'CSV', _('CSV with column headers')

    vessel = models.ForeignKey(Vessel, on_delete=models.CASCADE)
    submitter = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    license = models.ForeignKey(License, on_delete=models.SET_NULL, null=True)
    uploaded_on = models.DateTimeField('date uploaded',default=timezone.now)
    processing_status = models.CharField(max_length=3, blank=True, choices=ProcessingStatus.choices, default=ProcessingStatus.NEW)
    rawfile = models.FileField(upload_to='raw_tracks/')
    format = models.CharField(max_length=3,blank=True,choices=FileFormat.choices,default="")
    note = models.CharField('optional uploaders\' note',max_length=200,blank=True,default="")
    quality = models.IntegerField('a track quality measure from 0 (unusable) to 100 (perfect)', default=0)
    nPoints = models.IntegerField('number of points in track', null=True)
    def __str__(self):
        return _('[Track %d] (on %s %s, submitted by %s on %s)') % (self.pk,Vessel.VesselType(self.vessel.vtype).label,self.vessel.name,str(self.submitter),self.uploaded_on)

class Sounding(IndexManagerMixin,models.Model):
    MAX_LEVEL = 17

    coord = models.PointField(dim=2, srid=3857,spatial_index=True)
    z = models.FloatField()
    min_level = models.PositiveSmallIntegerField(default=MAX_LEVEL+1)
    track = models.ForeignKey(Track, on_delete=models.CASCADE)

    class Meta:
        indexes = [
            # consider combining coord and min_level indices
            models.Index(name='coord_idx', fields=['coord'],opclasses=['GIST_GEOMETRY_OPS_ND']), # ,'min_level'consider adding condition=Q(id__lt=0)
            models.Index(name='min_level_idx', fields=['min_level']),
            models.Index(name='track_idx', fields=['track']),
            models.Index(name='z_idx', fields=['z']),
        ]
