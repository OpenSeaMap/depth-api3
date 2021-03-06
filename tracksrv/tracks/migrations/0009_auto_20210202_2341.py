# Generated by Django 3.1.5 on 2021-02-02 22:41

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('vessels', '__first__'),
        ('tracks', '0008_auto_20210202_1606'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='vessel',
            name='submitter',
        ),
        migrations.AlterModelOptions(
            name='processingstatus',
            options={'ordering': ['-last_update'], 'verbose_name_plural': 'processing statuses'},
        ),
        migrations.AlterField(
            model_name='track',
            name='vessel',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='vessels.vessel'),
        ),
        migrations.DeleteModel(
            name='DepthUser',
        ),
        migrations.DeleteModel(
            name='Vessel',
        ),
    ]
