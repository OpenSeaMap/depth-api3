import io
import time
import datetime
from multiprocessing import Pool, TimeoutError
from os import sched_getaffinity

import numpy as np
from scipy.interpolate import griddata

from django.shortcuts import render
from django.http import FileResponse, HttpResponse, JsonResponse
from django.contrib.gis.geos import GEOSGeometry, Polygon
from django.utils.cache import patch_response_headers
from django.views.decorators.http import condition

#import tiles.transform as tf

import tiles.contour,tiles.debug
from tracks.models import Track,Sounding

source_reloaded = datetime.datetime.today()

#import redis

# initialize a global process pool
#cpus = len(sched_getaffinity(0))
#processPool = Pool(processes = max(1,cpus-1))

from tiles.util import NoTile, tile_to_3857, setup_fig_ax, get_figcontents, tileLock

def _gettile(z,xi,yi,func):
#    print("called _gettile")
    x0,y0,x1,y1 = *tile_to_3857(z,xi-1,yi+2), *tile_to_3857(z,xi+2,yi-1)
    bbox = Polygon.from_bbox((x0,y0,x1,y1))
    bbox.srid = 3857

    pts_q = Sounding.objects.filter(min_level__lte=z, coord__contained=bbox)

    npts = pts_q.count()

    if npts == 0:
#        print("_gettile(%d,%d,%d), 0 points"%(z,xi,yi))
        resp = HttpResponse("empty tile")
        resp.status_code = 204
        return resp

    pts      = np.empty((npts,2),float)
    pts[:,0] = np.fromiter((p.coord.transform(3857,clone=True).x for p in pts_q), float)
    pts[:,1] = np.fromiter((p.coord.transform(3857,clone=True).y for p in pts_q), float)
    depth    = np.fromiter((p.coord.z for p in pts_q),float)

    try:
        s = func(z,xi,yi,pts,depth)
    except NoTile:
        resp = HttpResponse("empty tile")
        resp.status_code = 204
        return resp

    resp = FileResponse(io.BytesIO(s), as_attachment = False)
    resp['Content-Type'] = 'image/png'
    patch_response_headers(resp, cache_timeout=30) # timeout 30 seconds

    return resp

@condition(last_modified_func=(lambda request,z,xi,yi:source_reloaded))
def contour(request,z,xi,yi):
    """
    return a tile with contour lines
    """

    return _gettile(z,xi,yi,tiles.contour.tile)

@condition(last_modified_func=(lambda request,z,xi,yi:source_reloaded))
def track(request,z,xi,yi):
    """
    return a tile with contour lines
    """

    track = request.GET.get('track',default=None)
    return _gettile(z,xi,yi,tiles.debug.points)

@condition(last_modified_func=(lambda request,z,xi,yi:source_reloaded))
def delaunay(request,z,xi,yi,track=None):
    """
    return a tile with contour lines
    """

#    print("called delaunay")
    return _gettile(z,xi,yi,tiles.debug.delaunay)
