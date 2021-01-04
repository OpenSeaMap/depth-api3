#import datetime
from django.utils import timezone
from django.db import models
from django.utils.translation import gettext_lazy as _

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

    name = models.CharField('the vessel name',max_length=128)
    created_on = models.DateTimeField('date created in database',default=timezone.now)
    length = models.FloatField('length in meters')
    beam = models.FloatField('beam in meters')
    draft = models.FloatField('draft in meters')
    height = models.FloatField('height in meters', null=True)
    displacement = models.FloatField('displacement in metric tons')
    manufacturer = models.CharField('the name of the manufacturer',max_length=128)
    model = models.CharField('the model/type of vessel as given by the manufacturer',max_length=128)
    vtype = models.CharField(max_length=2, choices=VesselType.choices)
    depth_sensor_offset_x = models.FloatField('distance from stern in meters')
    depth_sensor_offset_y = models.FloatField('distance from centerline in meters')
    depth_sensor_offset_z = models.FloatField('position below waterline in meters')
    gps_sensor_offset_x = models.FloatField('lateral offset of GPS sensor in meters')
    gps_sensor_offset_y = models.FloatField('longitudinal offset of GPS sensor in meters')
    gps_sensor_offset_z = models.FloatField('position above waterline in meters')
    measurement_type = models.CharField(max_length=2, null=True, choices=MeasurementType.choices)
    depth_sensor_offset_keel = models.FloatField(null=True) # XXX what is this?
    depth_sensor_manufacturer = models.CharField(max_length=32, null=True)
    depth_sensor_model = models.CharField(max_length=20, null=True)
    def __str__(self):
        return '%s %s (%s %s) (%2.1fm/%1.1fm/%1.1fm/%1.1ft)'%(Vessel.VesselType(self.vtype).label,self.name,self.manufacturer,self.model,self.length,self.beam,self.draft,self.displacement)

class User(models.Model):
    first_name = models.CharField(max_length=32)
    last_name = models.CharField(max_length=32)
    created_on = models.DateTimeField(default=timezone.now)
    def __str__(self):
        return ' '.join((self.first_name,self.last_name))

class Track(models.Model):
    class ProcessingStatus(models.TextChoices):
        NEW = 'NEW', _('New')
        INGESTING = 'ING', _('Ingesting')
        DONE = 'DNE', _('Done')

    vessel = models.ForeignKey(Vessel, on_delete=models.CASCADE)
    submitter = models.ForeignKey(User, on_delete=models.CASCADE)
    uploaded_on = models.DateTimeField('date uploaded',default=timezone.now)
    processing_status = models.CharField(max_length=3, null=True, choices=ProcessingStatus.choices)
    rawfile = models.FileField(upload_to='raw_tracks/')
    note = models.CharField('optional uploaders\' note',max_length=200)
    quality = models.IntegerField('a track quality measure from 0 (unusable) to 100 (perfect)',default=0)
    def __str__(self):
        return '[%d] (%s %s, submitted by %s on %s)' % (self.id,Vessel.VesselType(self.vessel.vtype).label,self.vessel.name,str(self.submitter),self.uploaded_on)
