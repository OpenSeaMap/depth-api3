from rest_framework import viewsets
from rest_framework import permissions

from users.permissions import IsSubmitter
from .serializers import VesselSerializer
from .models import Vessel

class VesselViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows vessels to be viewed or edited.
    """
    queryset = Vessel.objects.all().order_by('id')
    serializer_class = VesselSerializer
    permission_classes = [permissions.IsAuthenticated, IsSubmitter]
