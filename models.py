# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models


class AuthGroup(models.Model):
    name = models.CharField(unique=True, max_length=150)

    class Meta:
        managed = False
        db_table = 'auth_group'


class AuthGroupPermissions(models.Model):
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)
    permission = models.ForeignKey('AuthPermission', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_group_permissions'
        unique_together = (('group', 'permission'),)


class AuthPermission(models.Model):
    name = models.CharField(max_length=255)
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING)
    codename = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'auth_permission'
        unique_together = (('content_type', 'codename'),)


class AuthUser(models.Model):
    password = models.CharField(max_length=128)
    last_login = models.DateTimeField(blank=True, null=True)
    is_superuser = models.BooleanField()
    username = models.CharField(unique=True, max_length=150)
    first_name = models.CharField(max_length=150)
    last_name = models.CharField(max_length=150)
    email = models.CharField(max_length=254)
    is_staff = models.BooleanField()
    is_active = models.BooleanField()
    date_joined = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'auth_user'


class AuthUserGroups(models.Model):
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_groups'
        unique_together = (('user', 'group'),)


class AuthUserUserPermissions(models.Model):
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    permission = models.ForeignKey(AuthPermission, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_user_permissions'
        unique_together = (('user', 'permission'),)


class Depthsensor(models.Model):
    vesselconfigid = models.ForeignKey('Vesselconfiguration', models.DO_NOTHING, db_column='vesselconfigid')
    x = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    y = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    z = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    sensorid = models.CharField(max_length=-1, blank=True, null=True)
    manufacturer = models.CharField(max_length=100, blank=True, null=True)
    model = models.CharField(max_length=100, blank=True, null=True)
    frequency = models.DecimalField(max_digits=5, decimal_places=0, blank=True, null=True)
    angleofbeam = models.DecimalField(max_digits=3, decimal_places=0, blank=True, null=True)
    offsetkeel = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    offsettype = models.CharField(max_length=12, blank=True, null=True)
    id = models.BigAutoField(primary_key=True)

    class Meta:
        managed = False
        db_table = 'depthsensor'


class DjangoAdminLog(models.Model):
    action_time = models.DateTimeField()
    object_id = models.TextField(blank=True, null=True)
    object_repr = models.CharField(max_length=200)
    action_flag = models.SmallIntegerField()
    change_message = models.TextField()
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING, blank=True, null=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'django_admin_log'


class DjangoContentType(models.Model):
    app_label = models.CharField(max_length=100)
    model = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'django_content_type'
        unique_together = (('app_label', 'model'),)


class DjangoMigrations(models.Model):
    app = models.CharField(max_length=255)
    name = models.CharField(max_length=255)
    applied = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_migrations'


class DjangoSession(models.Model):
    session_key = models.CharField(primary_key=True, max_length=40)
    session_data = models.TextField()
    expire_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_session'


class Gauge(models.Model):
    id = models.IntegerField(primary_key=True)
    name = models.CharField(max_length=255)
    gaugetype = models.CharField(max_length=10, blank=True, null=True)
    lat = models.DecimalField(max_digits=11, decimal_places=3, blank=True, null=True)
    lon = models.DecimalField(max_digits=11, decimal_places=3, blank=True, null=True)
    geom = models.TextField(blank=True, null=True)  # This field type is a guess.
    provider = models.CharField(max_length=-1, blank=True, null=True)
    water = models.CharField(max_length=-1, blank=True, null=True)
    remoteid = models.CharField(max_length=-1, blank=True, null=True)
    waterlevel = models.DecimalField(max_digits=6, decimal_places=2, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'gauge'


class Gaugemeasurement(models.Model):
    gaugeid = models.ForeignKey(Gauge, models.DO_NOTHING, db_column='gaugeid')
    value = models.DecimalField(max_digits=4, decimal_places=2)
    time = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'gaugemeasurement'
        unique_together = (('gaugeid', 'time'),)


class License(models.Model):
    name = models.CharField(max_length=255)
    shortname = models.CharField(max_length=16, blank=True, null=True)
    text = models.TextField(blank=True, null=True)
    public = models.BooleanField(blank=True, null=True)
    user_name = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'license'


class RplJournal(models.Model):
    id = models.BigAutoField(primary_key=True)
    table_name = models.CharField(max_length=50)
    row_id = models.BigIntegerField()
    opcode = models.CharField(max_length=1)
    time_stamp = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'rpl_journal'


class Sbassensor(models.Model):
    vesselconfigid = models.ForeignKey('Vesselconfiguration', models.DO_NOTHING, db_column='vesselconfigid')
    x = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    y = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    z = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    sensorid = models.CharField(max_length=-1, blank=True, null=True)
    manufacturer = models.CharField(max_length=100, blank=True, null=True)
    model = models.CharField(max_length=100, blank=True, null=True)
    id = models.BigAutoField(primary_key=True)

    class Meta:
        managed = False
        db_table = 'sbassensor'


class SpatialRefSys(models.Model):
    srid = models.IntegerField(primary_key=True)
    auth_name = models.CharField(max_length=256, blank=True, null=True)
    auth_srid = models.IntegerField(blank=True, null=True)
    srtext = models.CharField(max_length=2048, blank=True, null=True)
    proj4text = models.CharField(max_length=2048, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'spatial_ref_sys'


class TmpTgUserProfiles(models.Model):
    user_name = models.CharField(max_length=256, blank=True, null=True)
    password = models.CharField(max_length=40, blank=True, null=True)
    salt = models.CharField(max_length=10, blank=True, null=True)
    attempts = models.SmallIntegerField(blank=True, null=True)
    last_attempt = models.DateTimeField(blank=True, null=True)
    forename = models.CharField(max_length=-1, blank=True, null=True)
    surname = models.CharField(max_length=-1, blank=True, null=True)
    country = models.CharField(max_length=-1, blank=True, null=True)
    language = models.CharField(max_length=-1, blank=True, null=True)
    organisation = models.CharField(max_length=-1, blank=True, null=True)
    phone = models.CharField(max_length=-1, blank=True, null=True)
    acceptedemailcontact = models.BooleanField(blank=True, null=True)
    num_tracks = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'tmp_tg_user_profiles'


class TmpTgUserTracks20181203(models.Model):
    track_id = models.BigIntegerField(blank=True, null=True)
    user_name = models.CharField(max_length=40, blank=True, null=True)
    file_ref = models.CharField(max_length=255, blank=True, null=True)
    upload_state = models.SmallIntegerField(blank=True, null=True)
    filetype = models.CharField(max_length=80, blank=True, null=True)
    compression = models.CharField(max_length=80, blank=True, null=True)
    containertrack = models.IntegerField(blank=True, null=True)
    vesselconfigid = models.IntegerField(blank=True, null=True)
    license = models.IntegerField(blank=True, null=True)
    gauge_name = models.CharField(max_length=100, blank=True, null=True)
    gauge = models.DecimalField(max_digits=6, decimal_places=2, blank=True, null=True)
    height_ref = models.CharField(max_length=100, blank=True, null=True)
    comment = models.CharField(max_length=-1, blank=True, null=True)
    watertype = models.CharField(max_length=20, blank=True, null=True)
    uploaddate = models.DateTimeField(blank=True, null=True)
    bbox = models.TextField(blank=True, null=True)  # This field type is a guess.

    class Meta:
        managed = False
        db_table = 'tmp_tg_user_tracks_2018_12_03'


class TrackInfo(models.Model):
    id = models.BigAutoField(primary_key=True)
    tra = models.ForeignKey('UserTracks', models.DO_NOTHING)
    short_info = models.CharField(max_length=20, blank=True, null=True)
    long_info = models.CharField(max_length=-1, blank=True, null=True)
    reprocess = models.BooleanField(blank=True, null=True)
    discard = models.BooleanField(blank=True, null=True)
    ignore = models.BooleanField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'track_info'


class Trackgauges(models.Model):
    trackid = models.ForeignKey('UserTracks', models.DO_NOTHING, db_column='trackid', blank=True, null=True)
    gaugeid = models.ForeignKey(Gauge, models.DO_NOTHING, db_column='gaugeid', blank=True, null=True)
    source = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'trackgauges'


class UserProfiles(models.Model):
    user_name = models.CharField(unique=True, max_length=256)
    password = models.CharField(max_length=40, blank=True, null=True)
    salt = models.CharField(max_length=10, blank=True, null=True)
    attempts = models.SmallIntegerField()
    last_attempt = models.DateTimeField(blank=True, null=True)
    forename = models.CharField(max_length=-1, blank=True, null=True)
    surname = models.CharField(max_length=-1, blank=True, null=True)
    country = models.CharField(max_length=-1, blank=True, null=True)
    language = models.CharField(max_length=-1, blank=True, null=True)
    organisation = models.CharField(max_length=-1, blank=True, null=True)
    phone = models.CharField(max_length=-1, blank=True, null=True)
    acceptedemailcontact = models.BooleanField(blank=True, null=True)
    id = models.BigAutoField(primary_key=True)

    class Meta:
        managed = False
        db_table = 'user_profiles'


class UserTracks(models.Model):
    track_id = models.BigAutoField(primary_key=True)
    user_name = models.CharField(max_length=40)
    file_ref = models.CharField(max_length=255, blank=True, null=True)
    upload_state = models.SmallIntegerField(blank=True, null=True)
    filetype = models.CharField(max_length=80, blank=True, null=True)
    compression = models.CharField(max_length=80, blank=True, null=True)
    containertrack = models.ForeignKey('self', models.DO_NOTHING, db_column='containertrack', blank=True, null=True)
    vesselconfigid = models.ForeignKey('Vesselconfiguration', models.DO_NOTHING, db_column='vesselconfigid', blank=True, null=True)
    license = models.IntegerField(blank=True, null=True)
    gauge_name = models.CharField(max_length=100, blank=True, null=True)
    gauge = models.DecimalField(max_digits=6, decimal_places=2, blank=True, null=True)
    height_ref = models.CharField(max_length=100, blank=True, null=True)
    comment = models.CharField(max_length=-1, blank=True, null=True)
    watertype = models.CharField(max_length=20, blank=True, null=True)
    uploaddate = models.DateTimeField(blank=True, null=True)
    bbox = models.TextField(blank=True, null=True)  # This field type is a guess.
    clusteruuid = models.CharField(max_length=-1, blank=True, null=True)
    clusterseq = models.BigIntegerField(blank=True, null=True)
    upr = models.ForeignKey(UserProfiles, models.DO_NOTHING)
    num_points = models.IntegerField(blank=True, null=True)
    is_container = models.BooleanField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'user_tracks'


class Userroles(models.Model):
    user_name = models.CharField(max_length=250, blank=True, null=True)
    role = models.CharField(max_length=15, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'userroles'


class Vesselconfiguration(models.Model):
    name = models.CharField(max_length=-1, blank=True, null=True)
    description = models.CharField(max_length=-1, blank=True, null=True)
    user_name = models.CharField(max_length=-1, blank=True, null=True)
    mmsi = models.CharField(max_length=20, blank=True, null=True)
    manufacturer = models.CharField(max_length=100, blank=True, null=True)
    model = models.CharField(max_length=-1, blank=True, null=True)
    loa = models.DecimalField(max_digits=7, decimal_places=2, blank=True, null=True)
    breadth = models.DecimalField(max_digits=7, decimal_places=2, blank=True, null=True)
    draft = models.DecimalField(max_digits=4, decimal_places=2, blank=True, null=True)
    height = models.DecimalField(max_digits=4, decimal_places=2, blank=True, null=True)
    displacement = models.DecimalField(max_digits=8, decimal_places=1, blank=True, null=True)
    maximumspeed = models.DecimalField(max_digits=3, decimal_places=1, blank=True, null=True)
    type = models.IntegerField(blank=True, null=True)
    upr = models.ForeignKey(UserProfiles, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'vesselconfiguration'
