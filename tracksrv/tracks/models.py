import datetime
from django.db import models

# Create your models here.

"""
CREATE TABLE "public"."tracks" (
    "id" integer DEFAULT nextval('tracks_id_seq') PRIMARY KEY,
    "vessel_id" integer NOT NULL,
    "submitter_id" integer NOT NULL,
    "created_on" timestamp NOT NULL,
    "processing_status" processing_status NOT NULL,
    "rawfile" integer NOT NULL,
    "note" character varying(128),
    "quality" smallint,
    CONSTRAINT "tracks_submitter_id_fkey" FOREIGN KEY (submitter_id) REFERENCES users(id)  ON DELETE CASCADE NOT DEFERRABLE,
    CONSTRAINT "tracks_vessel_id_fkey" FOREIGN KEY (vessel_id) REFERENCES vessels(id)  ON DELETE CASCADE NOT DEFERRABLE
) WITH (oids = false);
"""

class ProcessingStatus(models.Model):
    status = models.CharField('processing machine state', max_length=16)
    def __str__(self):
        return self.status

ProcessingStatus.objects.create(status='new')
ProcessingStatus.objects.create(status='ingesting')
ProcessingStatus.objects.create(status='done')

"""
CREATE TABLE "public"."vessels" (
    "id" integer DEFAULT nextval('vessels_id_seq') PRIMARY KEY,
    "name" character varying(50),
    "created_on" timestamp NOT NULL,
    "length" real NOT NULL,
    "beam" real NOT NULL,
    "draft" real NOT NULL,
    "displacement" real NOT NULL,
    "manufacturer" character varying(50) NOT NULL,
    "model" character varying(50) NOT NULL,
    "type" character varying(30) NOT NULL,
    "depth_sensor_offs_x" real NOT NULL,
    "depth_sensor_offs_y" real NOT NULL,
    "depth_sensor_offs_z" real NOT NULL,
    "measurement_type" character(20) NOT NULL,
    "depth_sensor_offset_keel" smallint NOT NULL,
    "depth_sensor_manufacturer" character varying(30) NOT NULL,
    "depth_sensor_model" character(20) NOT NULL,
    "gps_sensor_offs_x" real NOT NULL,
    "gps_sensor_offs_y" real NOT NULL,
    "gps_sensor_offs_z" real NOT NULL,
    "gps_sensor_manufacturer" character varying(30) NOT NULL,
    "gps_sensor_model" character(1) NOT NULL,
    CONSTRAINT "vessels_id_key" UNIQUE ("id")
) WITH (oids = false);
"""

class Vessel(models.Model):
    def now():
        return datetime.today()
    name = models.CharField('the vessel name',max_length=128)
    created_on = models.DateTimeField('date created in database',default=now)
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

"""
CREATE TABLE "public"."users" (
    "id" integer DEFAULT nextval('users_id_seq') PRIMARY KEY,
    "first_name" character varying(30),
    "last_name" character varying(30),
    "created_on" timestamp NOT NULL,
    CONSTRAINT "users_id_key" UNIQUE ("id")
) WITH (oids = false);
"""

class User(models.Model):
    def now():
        return datetime.today()

    first_name = models.CharField(max_length=32)
    last_name = models.CharField(max_length=32)
    created_on = models.DateTimeField(default=now)

def now():
    return datetime.today()
class Track(models.Model):

    vessel = models.ForeignKey(Vessel, on_delete=models.CASCADE)
    submitter = models.ForeignKey(User, on_delete=models.CASCADE)
    uploaded_on = models.DateTimeField('date uploaded',default=now)
    processing_status = models.ForeignKey(ProcessingStatus, null=True, on_delete=models.SET_NULL)
    rawfile = models.FileField(upload_to='raw_tracks/')
    note = models.CharField('optional uploaders\' note',max_length=200)
    quality = models.IntegerField('a track quality measure from 0 (unusable) to 100 (perfect)',default=0)

