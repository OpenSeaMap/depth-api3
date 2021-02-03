from .models import Vessel

from rest_framework import serializers

class VesselSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Vessel
        fields = ['submitter', 'name', 'created_on', 'length', 'beam', 'draft', 'height',
            'displacement', 'manufacturer', 'model', 'vtype']
