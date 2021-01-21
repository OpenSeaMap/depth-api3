from django.shortcuts import get_object_or_404,render

from django.http import HttpResponse,JsonResponse, FileResponse
from django.core.paginator import Paginator
from django.db.models import Count

from .models import Track,Sounding


def getTrackContext(request):
    page = request.GET.get('page',default=1) # XXX use next/prev style navigation
    limit = request.GET.get('limit',default=50)
    q = Track.objects.order_by('-uploaded_on').annotate(npoints=Count('sounding'))

    paginator = Paginator(q,per_page=limit)

    return [{'id':t.id,'vessel_id':t.vessel.id,'vessel_name':t.vessel.name,'uploaded_on':t.uploaded_on,'n_points':t.npoints} for t in paginator.get_page(page)]


def index(request):
    return JsonResponse(getTrackContext(request), safe=False)




def detail(request, track_id):
    if request.method == 'POST':
        vessel_id = request.GET.get('vessel')
        submitter_id = 1 # derive from logged-in user
        vessel = Vessel.object.get(pk=vessel_id)
        track = Track(vessel=vessel, submitter=submitter_id)
        track.save()
    else:
        track = get_object_or_404(Track, pk=track_id)
        trackDetail = {'id':track.id,'uploaded_on':track.uploaded_on,'n_soundings':Sounding.objects.filter(track=track).count()}
        return JsonResponse(trackDetail)

def raw(request, track_id):
    track = get_object_or_404(Track, pk=track_id)
    return FileResponse(track.rawfile,as_attachment=True)
