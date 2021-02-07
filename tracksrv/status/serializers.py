from .models import ProcessingStatus

from rest_framework import serializers

class StatusSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = ProcessingStatus
        fields = '__all__'
        read_only_fields = ['name','toProcess','nProcessed','start_time','last_update','end_time','track']

