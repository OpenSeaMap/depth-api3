from .models import License

from rest_framework import serializers

class LicenseSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = License
        fields = '__all__'
