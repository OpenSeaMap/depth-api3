#import datetime
from django.utils import timezone
from django.db import models

# Create your models here.

class ProcessingStatus(models.Model):
    status = models.CharField('processing machine state', max_length=16)
    def __str__(self):
        return self.status

#ProcessingStatus.objects.create(status='new')
#ProcessingStatus.objects.create(status='ingesting')
#ProcessingStatus.objects.create(status='done')


class Vessel(models.Model):
    name = models.CharField('the vessel name',max_length=128)
    created_on = models.DateTimeField('date created in database',default=timezone.now)
    length = models.FloatField('length in meters')
    beam = models.FloatField('beam in meters')
    draft = models.FloatField('draft in meters')
    displacement = models.FloatField('displacement in metric tons')
    manufacturer = models.CharField('the name of the manufacturer',max_length=128)
    model = models.CharField('the model/type of vessel as given by the manufacturer',max_length=128)
    vtype = models.CharField('the type of vessel',max_length=32)
    depth_sensor_offset_x = models.FloatField('lateral offset of depth sensor in meters')
    depth_sensor_offset_y = models.FloatField('longitudinal offset of depth sensor in meters')
    depth_sensor_offset_z = models.FloatField()
    gps_sensor_offset_x = models.FloatField('lateral offset of GPS sensor in meters')
    gps_sensor_offset_y = models.FloatField('longitudinal offset of GPS sensor in meters')
    gps_sensor_offset_z = models.FloatField()
#    measurement_type = models.CharField(max_length=20)
#    depth_sensor_offset_keel
#    depth_sensor_manufacturer = models.CharField(max_length=32)
#    depth_sensor_model = models.CharField(max_length=20)


class User(models.Model):
    first_name = models.CharField(max_length=32)
    last_name = models.CharField(max_length=32)
    created_on = models.DateTimeField(default=timezone.now)
    def __str__(self):
        return ' '.join((self.first_name,self.last_name))


class Track(models.Model):
    vessel = models.ForeignKey(Vessel, on_delete=models.CASCADE)
    submitter = models.ForeignKey(User, on_delete=models.CASCADE)
    uploaded_on = models.DateTimeField('date uploaded',default=timezone.now)
    processing_status = models.ForeignKey(ProcessingStatus, null=True, on_delete=models.SET_NULL)
    rawfile = models.FileField(upload_to='raw_tracks/')
    note = models.CharField('optional uploaders\' note',max_length=200)
    quality = models.IntegerField('a track quality measure from 0 (unusable) to 100 (perfect)',default=0)
