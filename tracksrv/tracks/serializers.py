from .models import Track

from rest_framework import serializers

class TrackSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Track
        fields = ['vessel','uploaded_on','rawfile','format','note','quality']
