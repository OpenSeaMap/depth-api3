from rest_framework import viewsets
from rest_framework import permissions
from django.contrib.auth.models import User

from .models import DepthUser
from .serializers import UserSerializer,AuthUserSerializer

class UserViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows users to be viewed or edited.
    """
    queryset = DepthUser.objects.all().order_by('user__last_name')
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]

class AuthUserViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows authenticated users to be viewed or edited.
    This is a hack -- we expect this view will go away again.
    """
    queryset = User.objects.all().order_by('last_name')
    serializer_class = AuthUserSerializer
    permission_classes = [permissions.IsAuthenticated]
