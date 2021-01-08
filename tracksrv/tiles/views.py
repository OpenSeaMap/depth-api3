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

import tiles.transform as tf
from tracks.models import Track,Sounding

#import redis

# initialize a global process pool
cpus = len(sched_getaffinity(0))
processPool = Pool(processes = max(1,cpus-1))

class Perf():
    def __init__(self):
        self.start = time.time()

    def done(self):
        return time.time()-self.start

def contour(request,z,x,y):
    """
    return a tile with contour lines
    """

    p = Perf()

    tpz = 2 ** z # two to (the power of) zoom

    #    boxcoords = "(({},{}),({},{}))".format(x2lon(tpz,xi-1),y2lat(tpz,yi-1),x2lon(tpz,xi+2),y2lat(tpz,yi+2))

    bbox = Polygon.from_bbox((tf.x2lon(tpz,x-1),tf.y2lat(tpz,y-1),tf.x2lon(tpz,x+2),tf.y2lat(tpz,y+2)))
    pts = Sounding.objects.filter(min_level__lte=z, coord__coveredby=bbox)
    npts = pts.count()
    if npts > 0:
        c_tile = np.empty((npts,2),float)
        depth  = np.empty((npts,1),float)

        i = 0
        for p in pts:
            c_tile[i,0] = tf.lon2x(tpz,p.coord[0])
            c_tile[i,1] = tf.lat2y(tpz,p.coord[1])
            depth[i]    = p.coord[2]

    msg = "we discovered %d points in %f ms"%(npts,p.done())
    print(msg)

    return HttpResponse(msg)

    return FileResponse(
        io.bytesIO(s),
        mimetype='image/png',
        last_modified = datetime.fromtimestamp(float(redis.hget(key,'last_modified'))),
        cache_timeout = tileRender.EXPIRE_SECS, # will be max_age in newer versions of flask
        as_attachment=False)
