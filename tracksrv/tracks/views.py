from django.db.models import F,Count

from rest_framework import viewsets
from rest_framework import permissions
from users.permissions import IsSubmitter
from .serializers import TrackSerializer
from .models import Track


class TrackViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows tracks to be viewed or edited.
    """
    queryset = Track.objects.all().order_by('-uploaded_on')
    serializer_class = TrackSerializer
    permission_classes = [permissions.IsAuthenticated, IsSubmitter]
