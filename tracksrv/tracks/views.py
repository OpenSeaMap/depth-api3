from django.shortcuts import get_object_or_404,render

from django.http import HttpResponse,JsonResponse
from django.core.paginator import Paginator

from .models import Track

def index(request):
    page=request.GET.get('page',default=1) # XXX use next/prev style navigation
    limit=request.GET.get('limit',default=50)
    paginator = Paginator(Track.objects.order_by('-uploaded_on'),per_page=limit)

    trackList = [{'id':t.id,'uploaded_on':t.uploaded_on} for t in paginator.get_page(page)]

    return JsonResponse(trackList, safe=False)

def detail(request, track_id):
    track = get_object_or_404(Track, pk=track_id)
    trackDetail = {'id':track.id,'uploaded_on':track.uploaded_on}
    return JsonResponse(trackDetail)

def raw(request, track_id):
    track = get_object_or_404(Track, pk=track_id)
    return HttpResponse("raw file for track %d"%(track_id,))
# use StreamingHttpResponse, or rather FileResponse
