# Generated by Django 3.1.5 on 2021-02-03 11:27

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='License',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=128)),
                ('url', models.URLField(null=True, verbose_name='link to the license')),
                ('copy', models.TextField(verbose_name='a copy of the license, in case the original license goes away')),
            ],
        ),
    ]