# Generated by Django 3.1.5 on 2021-02-03 11:30

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('licenses', '0001_initial'),
        ('vessels', '0003_auto_20210203_0001'),
    ]

    operations = [
        migrations.AddField(
            model_name='vessel',
            name='license',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to='licenses.license'),
        ),
    ]
