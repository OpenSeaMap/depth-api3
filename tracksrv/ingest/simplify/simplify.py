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
from tiles.util import tile_to_3857,Perf,Stat

def minTile(context,z,x,y):

  def q(z,x,y):
    bbox = Polygon.from_bbox((*tile_to_3857(z,x,y+1), *tile_to_3857(z,x+1,y)))
    bbox.srid = 3857
    return Sounding.objects.filter(track=track, coord__coveredby=bbox)

  def printProg(z,x,y,s):
    print(' '*(150),end='\r')
    print('z=%d, x=%d, y=%d %s'%(z,x,y,s),end='\r')

  with Perf() as p:
    pts = q(z,x,y)
    haspts = pts.exists()
  context['stat1'][z].add(p.t)

  if not haspts:
    return None

  if (z < 15 or pts.count() > 4**context['subdiv']) and z < context['maxlev']+context['subdiv']:
    c = [[2*x,2*y],[2*x+1,2*y],[2*x,2*y+1],[2*x+1,2*y+1]]

    # determine minimal sounding
    # XXX could smarten up when we update the database
    minimal = None
    for xx,yy in c:
      r = minTile(context,z+1,xx,yy)
      if r is not None:
        if (minimal is None) or (r['z'] < minimal['z']):
          minimal = r

  else:
    context['ps'].incProgress(pts.count())
    with Perf() as p:
      minimal = pts.annotate(mz=Min('z')).filter(mz=F('z')).values('id','z')[0]
    context['stat2'][z].add(p.t)

    with Perf() as p:
      pts.exclude(min_level=z+1).update(min_level=z+1)
    context['stat3'][z].add(p.t)

  # we now have minimal
  with Perf() as p:
    Sounding.objects.filter(id=minimal['id']).exclude(min_level=z-context['subdiv']).update(min_level=z-context['subdiv'])
  # we could stop the updating here -- if no change, or rather -- change here increases the min_level
  context['stat4'][z].add(p.t)

  if z == 15:
    printProg(z,x,y,str(context['ps']))

  return minimal

def printStat(title,stat):
  def r(h,c,hh=True):
    if hh:
      h += '%7d'%sum(c)
    else:
      h += ' '*7
    print('%s'%h,end=' ')

    for x in c:
      print('%7d'%x,end=' ')
    print()

  print()
  print(title)
  print('-'*len(title))

  r('i  ',range(len(stat)),False)
  r('cnt',[x.n for x in stat])
  r('ctm',[x.c for x in stat])
  r('atm',[1000*x.avg() for x in stat],False)

def simplifyFull(track,subdiv,maxlev):
  context={'subdiv':subdiv,'maxlev':maxlev}
  context['stat1'] = [Stat() for x in range(maxlev+subdiv+1)]
  context['stat2'] = [Stat() for x in range(maxlev+subdiv+1)]
  context['stat3'] = [Stat() for x in range(maxlev+subdiv+1)]
  context['stat4'] = [Stat() for x in range(maxlev+subdiv+1)]

  context['ps'] = ProcessingStatus(name="simp -s %d -m %d"%(subdiv,maxlev),
                                    track=track,
                                    toProcess=track.nPoints)
  context['ps'].save()

  minTile(context,0,0,0)

  context['ps'].end()

  printStat('all-search',context['stat1'])
  printStat('min-search',context['stat2'])
  printStat('all-update',context['stat3'])
  printStat('one-update',context['stat4'])


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

  tracks = Track.objects.exclude(sounding=None)
  if not args.force:
    tracks = tracks.annotate(minlev=Min('sounding__min_level')).exclude(minlev__lt=Sounding.MAX_LEVEL+1)

  if len(args.tracks) > 0:
    tracks = tracks.filter(id__in=args.tracks)

  if tracks.count() > 0:
    print("Processing tracks: %s"%[t.id for t in tracks])

    for track in tracks:
      logger.info("simplifying track %s",str(track))
      with Perf() as p:
        simplifyFull(track, args.subdiv,args.maxlev)
      logger.info("\nsimplification took %f s",p.t)
