from .models import Vessel

from rest_framework import serializers

class VesselSerializer(serializers.HyperlinkedModelSerializer):
#    id = serializers.HyperlinkedRelatedField(
#        read_only=True,
#        view_name='vessel-detail'
#    )
    class Meta:
        model = Vessel
        fields = '__all__'
