# Generated by Django 3.1.5 on 2021-01-29 12:59

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('tracks', '0006_auto_20210128_1239'),
    ]

    operations = [
        migrations.AlterField(
            model_name='track',
            name='format',
            field=models.CharField(blank=True, choices=[('GPX', 'Gpx'), ('183', 'NMEA 0183'), ('OSM', 'NMEA 0183 with OSM timestamps'), ('CSV', 'CSV with column headers')], default='', max_length=3),
        ),
    ]