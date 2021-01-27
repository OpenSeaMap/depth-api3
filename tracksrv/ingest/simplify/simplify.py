#!/usr/bin/python3

"""
looks for tracks where all soundings of that track have the min_level set to MAX_LEVEL or beyond

each such track is then simplified
"""

import xml.etree.ElementTree as ET
from itertools import islice
import logging
import time

logger = logging.getLogger(__name__)

import django
django.setup()

from django.db import connection
from django.db.models import Min, F, Func
from django.contrib.gis.geos import Point, GEOSGeometry, Polygon
#from django.contrib.gis.measure import Distance
from django.contrib.gis.db.models.functions import GeoFunc
from django.db.models.fields import FloatField

from tracks.models import Track,Sounding

import tiles.transform as tf
from tiles.util import tile_to_3857,Perf

def q(z,x,y):
  bbox = Polygon.from_bbox((*tile_to_3857(z,x,y+1), *tile_to_3857(z,x+1,y)))
  bbox.srid = 3857

  return Sounding.objects.filter(track=track, coord__coveredby=bbox)

def progress(z,x,y,p,t_rem):
  eta_s = time.localtime(time.time()+t_rem)
  eta_str = time.strftime("%c",eta_s)

  eta_m = t_rem//60
  t_rem -= eta_m*60
  eta_h = eta_m//60
  eta_m -= eta_h*60

  print('                                                                                    ',end='\r')
  print('z=%d, x=%d, y=%d (%2.1f%%) ETA=%02d:%02d:%02d (%s)'%(z,x,y,p,eta_h,eta_m,t_rem,eta_str),end='\r')

SUBDIV = 2

def minTile(context,z,x,y):
  if z < Sounding.MAX_LEVEL+SUBDIV:

    c = [[2*x,2*y],[2*x+1,2*y],[2*x,2*y+1],[2*x+1,2*y+1]]
    haspts = [[q(z+1,x,y).exists(),x,y] for x,y in c] # could do in parallel

    # determine minimal sounding
    # XXX could smarten up when we update the database
    minimal = None
    for e,xx,yy in haspts:
      if e:
        r = minTile(context,z+1,xx,yy)
        if r is not None:
          if (minimal is None) or r['z'] < minimal['z']:
            minimal = r

  else:
    pts = q(z,x,y)
    context['nProcessed'] += pts.count()
    minimal = pts.annotate(mz=Min('z')).filter(mz=F('z')).values('id','z')[0]

  # we now have minimal
  Sounding.objects.filter(id=minimal['id']).update(min_level=z-SUBDIV)

  if z == 15 and context['nProcessed']>0:
    f = context['nProcessed']/context['nTotal']
    eta_in_s = (time.time()-context['start'])/f*(1-f)

    progress(z,x,y,100.*f,eta_in_s)

  return minimal

def simplifyFull(track,grid):
  context={}
  Sounding.objects.filter(track=track).update(min_level=Sounding.MAX_LEVEL+1)
  context['nTotal'] = Sounding.objects.filter(track=track).count()
  context['nProcessed'] = 0
  context['start'] = time.time()
  minTile(context,0,0,0)

if __name__ == "__main__":
  print("Simplify")
  tracks = list(Track.objects.exclude(sounding=None).annotate(minlev=Min('sounding__min_level')).exclude(minlev__lt=Sounding.MAX_LEVEL))

  # drop min_level index to avoid re-indexing during write operations
  with connection.cursor() as cursor:
    logger.debug("dropping index")
    cursor.execute("DROP INDEX tracks_sounding_min_level_744b912d")

  try:
    for track in tracks:
      logger.info("simplifying track %s",str(track))
      p = Perf()
      simplifyFull(track, 256)
      logger.info("simplification took %f s",p.done())

  finally:
    # re-create min_level index
    with connection.cursor() as cursor:
      logger.debug("recreating index")
      cursor.execute("CREATE INDEX tracks_sounding_min_level_744b912d ON tracks_sounding (min_level)")
