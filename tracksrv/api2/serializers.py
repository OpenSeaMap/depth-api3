from rest_framework import serializers
from . import gauge


class GaugeSerializer(serializers.Serializer):
    id = serializers.IntegerField(read_only=True)
    name = serializers.CharField(max_length=256)
    latitude = serializers.CharField(max_length=256)
    longitude = serializers.CharField(max_length=256)
    gaugeType = serializers.CharField(max_length=256)
    waterlevel = serializers.CharField(max_length=256)

    def create(self, validated_data):
        return gauge(id=None, **validated_data)

    def update(self, instance, validated_data):
        for field, value in validated_data.items():
            setattr(instance, field, value)
        return instance
    
    '''
    // todo: analyse java implementation and transfer to python code   
    https://github.com/thomas-osm/depth_api2/blob/master/src/main/java/org/osm/depth/upload/resources/GaugeResource.java
    '''