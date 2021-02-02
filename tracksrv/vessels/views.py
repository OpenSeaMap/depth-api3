from django.contrib.auth.decorators import login_required, permission_required
from django.contrib.auth.mixins import LoginRequiredMixin,PermissionRequiredMixin
from django.shortcuts import get_object_or_404,render

from django.http import HttpResponse,JsonResponse, FileResponse
from django.core.paginator import Paginator
from django.db.models import F,Count

from .models import Vessel

from django.views import generic

class VesselDetailView(PermissionRequiredMixin,generic.DetailView):
    model = Vessel
    permission_required = 'tracks.view'

    """check that the user has permission to view the track detail.
    If they don't, return a 403 Forbidden"""
    def has_permission(self):
        return self.get_object().submitter == self.request.user
