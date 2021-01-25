#!/usr/bin/python3

"""
looks for tracks where all soundings of that track have the min_level set to MAX_LEVEL or beyond

each such track is then simplified
"""

import xml.etree.ElementTree as ET
from itertools import islice
import logging

logger = logging.getLogger(__name__)

import django
django.setup()

from django.db.models import Min, F, Func
from django.contrib.gis.geos import Point, GEOSGeometry, Polygon
#from django.contrib.gis.measure import Distance
from django.contrib.gis.db.models.functions import GeoFunc
from django.db.models.fields import FloatField

from tracks.models import Track,Sounding

import tiles.transform as tf
from tiles.util import tile_to_3857,Perf

class getZ(GeoFunc):
    function='ST_Z'
    geom_param_pos = (0,)
    output_field = FloatField()


SUBDIV = 2

def recurseDown(z,x,y):
  """ starting with 0,0,0, if there is a point in the tile, recurse

    if we are at the lowest level, find the shallowest point and enter it z+subdiv levels higher
  """

  if z == 15:
    logger.debug("LEVEL %d tile %d,%d",z,x,y)

  bbox = Polygon.from_bbox((*tile_to_3857(z,x,y+1), *tile_to_3857(z,x+1,y)))
  bbox.srid = 3857

  prf = Perf()
  pts = Sounding.objects.filter(track=track, coord__contained=bbox)

  if pts.exists():
    logger.debug("lookup took %f ms",prf.done()*1000.)

    prf = Perf()
    if z < Sounding.MAX_LEVEL+SUBDIV:

      pts = [recurseDown(z+1,2*x,2*y),  recurseDown(z+1,2*x+1,2*y),
             recurseDown(z+1,2*x,2*y+1),recurseDown(z+1,2*x+1,2*y+1)]

      for p_min in pts:
        if p_min is not None: break

      for p in pts:
        if p is not None and p['z'] < p_min['z']:
          p_min = p

    else:
      p_min = pts.annotate(z=getZ('coord')).annotate(mz=Min('z')).filter(mz=F('z')).values('id','z')[0]

    logger.debug("(%d) min took %f ms",z,prf.done()*1000.)

    prf = Perf()
    # some update statement
    Sounding.objects.filter(id=p_min['id']).update(min_level=z-SUBDIV)
    logger.debug("update took %f us",prf.done()*1000000.)

    return p_min

# else
  return None

def simplifyFull(track,grid):
  Sounding.objects.filter(track=track).update(min_level=Sounding.MAX_LEVEL+1)
  recurseDown(0,0,0)

def simplifyFast(track,grid):
#  Sounding.objects.filter(track=track).update(min_level=Sounding.MAX_LEVEL+1)
  p = Perf()
  q = Sounding.objects.filter(track=track).order_by('?').values('id')
  ids = [x['id'] for x in q]
  d = p.done()
  logger.debug('time(get_id)=%f (%f us per pt, %d pts)',d,d*1000000./len(ids),len(ids))

  total = 0
  for level in range(0,Sounding.MAX_LEVEL):
    logger.debug('level=%d',level)
    p = Perf()
    Sounding.objects.filter(id__in=ids[total:total+grid]).update(min_level=level)
    d = p.done()
    logger.debug('time(update)=%f (%f us per pt)',d,d*1000000./grid)
    total += grid
    grid *= 2

from django.db import connection

if __name__ == "__main__":
  print("Simplify")
  tracks = list(Track.objects.exclude(sounding=None).annotate(minlev=Min('sounding__min_level')).exclude(minlev__lt=Sounding.MAX_LEVEL))

  # drop min_level index to avoid re-indexing during write operations
  logger.debug("dropping index")
  with connection.cursor() as cursor:
    cursor.execute("DROP INDEX tracks_sounding_min_level_744b912d")

  try:
    for track in tracks:
      logger.info("simplifying track %s",str(track))
      p = Perf()
      simplifyFull(track, 256)
      logger.info("simplifaction took %f s",p.done())

  finally:
    # re-create min_level index
    logger.debug("recreating index")
    with connection.cursor() as cursor:
      cursor.execute("CREATE INDEX tracks_sounding_min_level_744b912d ON tracks_sounding (min_level)")
