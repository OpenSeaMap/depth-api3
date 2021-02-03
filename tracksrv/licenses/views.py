from rest_framework import viewsets
from .serializers import LicenseSerializer
from .models import License

class LicenseViewSet(viewsets.ModelViewSet):
    """
    API endpoint that allows vessels to be viewed or edited.
    """
    queryset = License.objects.all().order_by('id')
    serializer_class = LicenseSerializer
