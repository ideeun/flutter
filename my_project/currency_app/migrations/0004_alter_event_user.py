# Generated by Django 5.1.4 on 2025-01-02 10:12

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('currency_app', '0003_alter_event_user'),
    ]

    operations = [
        migrations.AlterField(
            model_name='event',
            name='user',
            field=models.CharField(max_length=100),
        ),
    ]