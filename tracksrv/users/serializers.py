from django.contrib.auth.models import User
from .models import DepthUser

from rest_framework import serializers

class UserSerializer(serializers.HyperlinkedModelSerializer):
    user = serializers.HyperlinkedRelatedField(view_name='authuser-detail',queryset=User.objects.all())
    class Meta:
        model = DepthUser
        fields = ['user', 'created_on', 'may_contact', 'last_attempt']

class AuthUserSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = User
        fields = ['first_name', 'last_name']
