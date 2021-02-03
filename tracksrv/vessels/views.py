from rest_framework import viewsets
from rest_framework import permissions

from users.permissions import IsSubmitter
from .serializers import VesselSerializer
from .models import Vessel

class VesselViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows vessels to be viewed or edited.
    """
    queryset = Vessel.objects.all()
    serializer_class = VesselSerializer
    permission_classes = [permissions.IsAuthenticated, IsSubmitter]


#class VesselDetailView(PermissionRequiredMixin,generic.DetailView):
#    model = Vessel
#    permission_required = 'tracks.view'

#    """check that the user has permission to view the track detail.
#    If they don't, return a 403 Forbidden"""
#    def has_permission(self):
#        return self.get_object().submitter == self.request.user
