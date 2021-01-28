#!/usr/bin/python3

"""
looks for tracks where all soundings of that track have the min_level set to MAX_LEVEL or beyond

each such track is then simplified
"""

import xml.etree.ElementTree as ET
from itertools import islice
import logging
import time
import argparse

logger = logging.getLogger(__name__)

import django
django.setup()

from django.db import connection
from django.db.models import Min, F, Func
from django.contrib.gis.geos import Point, GEOSGeometry, Polygon
#from django.contrib.gis.measure import Distance
from django.contrib.gis.db.models.functions import GeoFunc
from django.db.models.fields import FloatField
from django.utils import timezone

from tracks.models import Track,Sounding,ProcessingStatus

import tiles.transform as tf
from tiles.util import tile_to_3857,Perf

def q(z,x,y):
  bbox = Polygon.from_bbox((*tile_to_3857(z,x,y+1), *tile_to_3857(z,x+1,y)))
  bbox.srid = 3857

  return Sounding.objects.filter(track=track, coord__coveredby=bbox)

def printProg(z,x,y,s):
  print('                                                                                                ',end='\r')
  print('z=%d, x=%d, y=%d %s'%(z,x,y,s),end='\r')

def minTile(context,z,x,y):
  if z < Sounding.MAX_LEVEL+context['subdiv']:

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
    context['ps'].incProgress(pts.count())
    minimal = pts.annotate(mz=Min('z')).filter(mz=F('z')).values('id','z')[0]

  # we now have minimal
  Sounding.objects.filter(id=minimal['id']).update(min_level=z-context['subdiv'])

  if z == 15:
    printProg(z,x,y,str(context['ps']))

  return minimal

def simplifyFull(track,subdiv,maxlev):
  context={'subdiv':subdiv,'maxlev':maxlev}
  context['ps'] = ProcessingStatus(name="simplification",
                                    track=track,
                                    toProcess=Sounding.objects.filter(track=track).count())
  context['ps'].save()

  Sounding.objects.filter(track=track).update(min_level=maxlev+1)
  minTile(context,0,0,0)

  context['ps'].end()

if __name__ == "__main__":
  parser = argparse.ArgumentParser(description='Process soundings to limit number of soundings per tile.')
  parser.add_argument('-f', '--force', dest='force', action='store_true',
                      help='process track even if it has already been processed')
  parser.add_argument('-s', '--subdiv', dest='subdiv', action='store', type=int, default=2,
                      help='subdivision level')
  parser.add_argument('-m', '--maxlevel', dest='maxlev', action='store', type=int, default=Sounding.MAX_LEVEL,
                      help='maximum level')
  parser.add_argument('tracks', metavar='i', type=int, nargs='*',
                    help='a list of tracks to process. Leave empty for all tracks.')

  args = parser.parse_args()

  tracks = Track.objects.exclude(sounding=None).annotate(minlev=Min('sounding__min_level'))
  if not args.force:
    tracks = tracks.exclude(minlev__lt=Sounding.MAX_LEVEL)
  
  if len(args.tracks) > 0:
    tracks = tracks.filter(id__in=args.tracks)

  if tracks.count() > 0:
    print("Processing tracks: %s"%[t.id for t in tracks])

    # drop min_level index to avoid re-indexing during write operations
    with connection.cursor() as cursor:
      logger.debug("dropping index")
      cursor.execute("DROP INDEX tracks_sounding_min_level_744b912d")

    try:
      for track in tracks:
        logger.info("simplifying track %s",str(track))
        p = Perf()
        simplifyFull(track, args.subdiv,args.maxlev)
        logger.info("\nsimplification took %f s",p.done())

    finally:
      # re-create min_level index
      with connection.cursor() as cursor:
        logger.debug("recreating index")
        cursor.execute("CREATE INDEX tracks_sounding_min_level_744b912d ON tracks_sounding (min_level)")
