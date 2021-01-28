from django.contrib.auth.decorators import login_required, permission_required
from django.contrib.auth.mixins import LoginRequiredMixin,PermissionRequiredMixin
from django.shortcuts import get_object_or_404,render

from django.http import HttpResponse,JsonResponse, FileResponse
from django.core.paginator import Paginator
from django.db.models import F,Count

from .models import Track,Sounding,Vessel

from django.views import generic

class TrackListView(LoginRequiredMixin,generic.ListView):
    model = Track
    paginate_by = 10

    """override get_queryset to block access to all but the tracks that the user has uploaded.
    This also gives us a chance to annotate the track with a few helpful fields."""
    def get_queryset(self):
        qs = Track.objects
        if not self.request.user.is_staff:
            # only staff sees everything
            qs = qs.filter(submitter=self.request.user)
        qs = qs.order_by('-uploaded_on').annotate(npoints=Count('sounding'))

        return qs


class TrackDetailView(PermissionRequiredMixin,generic.DetailView):
    model = Track
    permission_required = 'tracks.view'

    """check that the user has permission to view the track detail.
    If they don't, return a 403 Forbidden"""
    def has_permission(self):
        return self.get_object().submitter == self.request.user

    def get_queryset(self):
        return super(TrackDetailView,self).get_queryset().annotate(npoints=Count('sounding'))

class VesselDetailView(PermissionRequiredMixin,generic.DetailView):
    model = Vessel
    permission_required = 'tracks.view'

    """check that the user has permission to view the track detail.
    If they don't, return a 403 Forbidden"""
    def has_permission(self):
        return self.get_object().submitter == self.request.user



#@permission_required('tracks.view')
#def detail(request, track_id):
#    if request.method == 'POST':
#        vessel_id = request.GET.get('vessel')
#        submitter_id = 1 # derive from logged-in user
#        vessel = Vessel.objects.get(pk=vessel_id)
#        track = Track(vessel=vessel, submitter=submitter_id)
#        track.save()
#    else:
#        track = get_object_or_404(Track, pk=track_id)
#        trackDetail = {'id':track.id,'uploaded_on':track.uploaded_on,'n_soundings':Sounding.objects.filter(track=track).count()}
#        return JsonResponse(trackDetail)

#def raw(request, track_id):
#    track = get_object_or_404(Track, pk=track_id)
#    return FileResponse(track.rawfile,as_attachment=True)
