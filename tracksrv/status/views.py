from django.db.models import F,Count

from rest_framework import viewsets
from rest_framework import permissions
from users.permissions import IsSubmitter
from .serializers import StatusSerializer
from .models import ProcessingStatus


class StatusViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows status to be viewed (not edited).
    """
    queryset = ProcessingStatus.objects.all().order_by('-last_update')
    serializer_class = StatusSerializer
    permission_classes = [permissions.IsAuthenticated, IsSubmitter]
