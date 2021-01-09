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

#import tiles.transform as tf
import tiles.contour
from tracks.models import Track,Sounding

#import redis

# initialize a global process pool
#cpus = len(sched_getaffinity(0))
#processPool = Pool(processes = max(1,cpus-1))

class Perf():
    def __init__(self):
        self.start = time.time()

    def done(self):
        return time.time()-self.start

EQUATOR = 40075016.68557849

def tile_to_3857(z,x,y):
  tpz = 2**z
  x =  x/tpz*EQUATOR - EQUATOR/2
  y = -y/tpz*EQUATOR + EQUATOR/2
  return x,y

def contour(request,z,x,y):
    """
    return a tile with contour lines
    """

    perf = Perf()

    bbox = Polygon.from_bbox((*tile_to_3857(z,x-1,y+2), *tile_to_3857(z,x+2,y-1)))
    bbox.srid = 3857

#    print(bbox)

    pts = Sounding.objects.filter(min_level__lte=z, coord__contained=bbox)
    npts = pts.count()
    msg = """we discovered %d points in %f ms
    """%(npts,1000*perf.done())
    if npts > 0:
        c_tile = np.empty((npts,2),float)

        c_tile[:,0] = np.fromiter((p.coord.transform(3857,clone=True).x for p in pts), float)
        c_tile[:,1] = np.fromiter((p.coord.transform(3857,clone=True).y for p in pts), float)
        depth       = np.fromiter((p.coord.z for p in pts),float)

        msg += "we discovered and copied %d points in %f ms"%(npts,1000*perf.done())
        print(msg)
#        print()

#        print(pts[0].coord)
#        print(c_tile)
#        print(depth)

#        return HttpResponse(msg)

        s = tiles.contour.tile(z,x,y,c_tile,depth)
    else:
        return HttpResponse("")

    fr = FileResponse(
        io.BytesIO(s),
        as_attachment = False)
    fr['Content-Type'] = 'image/png'
    patch_response_headers(fr,30)
    
    return fr
