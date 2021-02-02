# Generated by Django 3.1.5 on 2021-01-26 22:43

import django.contrib.gis.db.models.fields
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('tracks', '0002_auto_20210125_1851'),
    ]

    operations = [
        migrations.AddField(
            model_name='sounding',
            name='z',
            field=models.FloatField(db_index=True, default=0),
            preserve_default=False,
        ),
        migrations.AlterField(
            model_name='sounding',
            name='coord',
            field=django.contrib.gis.db.models.fields.PointField(db_index=True, srid=4326),
        ),
    ]