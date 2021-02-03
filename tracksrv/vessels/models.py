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
    created_on = models.DateField('date created in database',default=timezone.now)
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
