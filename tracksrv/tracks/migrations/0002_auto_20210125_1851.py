# Generated by Django 3.1.5 on 2021-01-25 17:51

import django.contrib.gis.db.models.fields
from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('tracks', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='sounding',
            name='coord',
            field=django.contrib.gis.db.models.fields.PointField(db_index=True, dim=3, srid=4326),
        ),
    ]
