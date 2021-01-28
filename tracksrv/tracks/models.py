from datetime import timedelta
from django.utils import timezone
from django.contrib.gis.db import models
from django.utils.translation import gettext_lazy as _
from django.contrib.auth.models import User

class Vessel(models.Model):
    class MeasurementType(models.TextChoices):
        BELOW_TRANSDUCER = 'BT', _('depth below transducer')
        BELOW_KEEL = 'BK', _('depth below keel')
        BELOW_WATERLINE = 'BW', _('depth below waterline')

    class VesselType(models.TextChoices):
        SAILING_YACHT = 'SY', _('Sailing Yacht')
        MOTOR_BOAT = 'MB', _('motorboat (planing hull)')
        MOTOR_YACHT = 'MY', _('Motor Yacht (displacement hull)')
        RUDDER_BOAT = 'RB', _('Rudder Boat')
        KAJAK = 'KJ', _('Kajak')
        DINGHY ='DG', _('Dinghy')

    submitter = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    name = models.CharField('the vessel name',max_length=128)
    created_on = models.DateTimeField('date created in database',default=timezone.now)
    length = models.FloatField('length in meters')
    beam = models.FloatField('beam in meters')
    draft = models.FloatField('draft in meters')
    height = models.FloatField('height in meters')
    displacement = models.FloatField('displacement in metric tons')
    manufacturer = models.CharField('the name of the manufacturer',blank=True,max_length=128)
    model = models.CharField('the model/type of vessel as given by the manufacturer',blank=True,max_length=128)
    vtype = models.CharField(max_length=2, choices=VesselType.choices)
    depth_sensor_offset_x = models.FloatField('distance of transducer from stern in meters')
    depth_sensor_offset_y = models.FloatField('distance of transducer from centerline in meters')
    depth_sensor_offset_z = models.FloatField('position of transducer below waterline in meters')
    gps_sensor_offset_x = models.FloatField('lateral offset of GPS sensor in meters')
    gps_sensor_offset_y = models.FloatField('longitudinal offset of GPS sensor in meters')
    gps_sensor_offset_z = models.FloatField('position above waterline in meters')
    measurement_type = models.CharField(max_length=2, null=True, choices=MeasurementType.choices)
    depth_sensor_offset_keel = models.FloatField(null=True, blank=True) # XXX what is this?
    depth_sensor_manufacturer = models.CharField(max_length=32, blank=True, default="")
    depth_sensor_model = models.CharField(max_length=20, blank=True, default="")
    def __str__(self):
        return '%s %s (%s %s) (%2.1fm/%1.1fm/%1.1fm/%1.1ft)'%(Vessel.VesselType(self.vtype).label,self.name,self.manufacturer,self.model,self.length,self.beam,self.draft,self.displacement)

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

    vessel = models.ForeignKey(Vessel, on_delete=models.CASCADE)
    submitter = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    uploaded_on = models.DateTimeField('date uploaded',default=timezone.now)
    processing_status = models.CharField(max_length=3, blank=True, choices=ProcessingStatus.choices, default=ProcessingStatus.NEW)
    rawfile = models.FileField(upload_to='raw_tracks/')
    format = models.CharField(max_length=3,blank=True,choices=FileFormat.choices,default="")
    note = models.CharField('optional uploaders\' note',max_length=200,blank=True,default="")
    quality = models.IntegerField('a track quality measure from 0 (unusable) to 100 (perfect)', default=0)
    def __str__(self):
        return '[Track %d] (on %s %s, submitted by %s on %s)' % (self.id,Vessel.VesselType(self.vessel.vtype).label,self.vessel.name,str(self.submitter),self.uploaded_on)

class ProcessingStatus(models.Model):
    name = models.CharField(max_length=20)
    toProcess = models.IntegerField(null=True)
    nProcessed = models.IntegerField(default=0)
    start_time = models.DateTimeField('date and time of start of operation',default=timezone.now)
    last_update = models.DateTimeField('date and time of last update',default=timezone.now)
    end_time = models.DateTimeField('date and time of start of operation',null=True)
    track = models.ForeignKey(Track, on_delete=models.CASCADE)

    def setProgress(self, nProcessed=None):
        self.last_update = timezone.now()
        if nProcessed is not None:
            self.nProcessed = nProcessed
        self.save()

    def incProgress(self, nProcessed):
        self.setProgress(self.nProcessed + nProcessed)

    def end(self):
        self.last_update = timezone.now()
        self.end_time    = self.last_update
        self.save()

    def percent_done(self):
        if self.toProcess is not None and self.toProcess > 0:
            return 100. * self.nProcessed / self.toProcess

    def time_left(self):
        p = self.percent_done()
        if p is not None:
            if p >= 100:
                return timedelta(seconds=0)
            else:
                return (timezone.now() - self.start_time) * (100-p)/p

    def ETA(self):
        tl = self.time_left()
        if tl is not None:
            return timezone.now() + tl

    def __str__(self):
        tl = self.time_left()
        if tl is not None:

            p = self.percent_done()
            assert p is not None
            return '%2.2f%% %s (%s)'%(p,tl,timezone.localtime(self.ETA()))
        else:
            td = timezone.now()-self.start_time
            return 'processed=%d (%1.0f / min)'%(self.nProcessed,self.nProcessed * 60 / td.total_seconds())

class Sounding(models.Model):
    MAX_LEVEL = 17

    coord = models.PointField(dim=2, srid=3857, db_index=True)
    z = models.FloatField(db_index=True)
    min_level = models.PositiveSmallIntegerField(db_index=True, default=MAX_LEVEL)
    track = models.ForeignKey(Track, db_index=True, on_delete=models.CASCADE)
