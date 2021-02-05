from .models import Track

from rest_framework import serializers

class TrackSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Track
        fields = '__all__' #['vessel','uploaded_on','rawfile','format','note','quality']
        read_only_fields = ['nPoints','quality','processing_status','uploaded_on','submitter']
