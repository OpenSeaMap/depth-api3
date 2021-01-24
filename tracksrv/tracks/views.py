from django.contrib.auth.decorators import login_required, permission_required
from django.shortcuts import get_object_or_404,render

from django.http import HttpResponse,JsonResponse, FileResponse
from django.core.paginator import Paginator
from django.db.models import Count

from .models import Track,Sounding,Vessel


def getTrackContext(request):
    page = request.GET.get('page',default=1) # XXX use next/prev style navigation
    limit = request.GET.get('limit',default=50)

    q = Track.objects
    if not request.user.is_staff:
        # staff sees everything
        q = q.filter(submitter=request.user)

    q = q.order_by('-uploaded_on').annotate(npoints=Count('sounding'))

    paginator = Paginator(q,per_page=limit)

    return dict(track_list=[{'id':t.id,'vessel_id':t.vessel.id,'vessel_name':t.vessel.name,'uploaded_on':t.uploaded_on,'n_points':t.npoints} for t in paginator.get_page(page)])

@permission_required('tracks.view')
def index(request):
    return JsonResponse(getTrackContext(request), safe=False)

@permission_required('tracks.view')
def html_index(request):
    return render(request, 'tracks_index.html', context=getTrackContext(request))

@permission_required('tracks.view')
def detail(request, track_id):
    if request.method == 'POST':
        vessel_id = request.GET.get('vessel')
        submitter_id = 1 # derive from logged-in user
        vessel = Vessel.objects.get(pk=vessel_id)
        track = Track(vessel=vessel, submitter=submitter_id)
        track.save()
    else:
        track = get_object_or_404(Track, pk=track_id)
        trackDetail = {'id':track.id,'uploaded_on':track.uploaded_on,'n_soundings':Sounding.objects.filter(track=track).count()}
        return JsonResponse(trackDetail)

def raw(request, track_id):
    track = get_object_or_404(Track, pk=track_id)
    return FileResponse(track.rawfile,as_attachment=True)
