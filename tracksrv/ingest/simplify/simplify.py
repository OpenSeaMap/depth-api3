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

from status.models import ProcessingStatus
from tracks.models import Track,Sounding

import tiles.transform as tf
from tiles.util import tile_to_3857,Perf,Stat


class HierachicalSimplifier:

  # the maximum number of points that should be left in a tile
  MAX_POINTS = 256

  # recurse, at a minimum, to this level
  MIN_RECURSE = 15

  def __init__(self,max_recurse,track=None):
    self.max_recurse = max(self.MIN_RECURSE,max_recurse)
    self.track = track
    self.allLookup = [Stat() for x in range(max_recurse+1)]
    self.oneLookup = [Stat() for x in range(max_recurse+1)]
    self.allUpdate = [Stat() for x in range(max_recurse+1)]
    self.oneUpdate = [Stat() for x in range(max_recurse+1)]
    # XXX TODO adapt for no-track simplification
    self.progress  = ProcessingStatus(name="simp -m %d %s"%(max_recurse,0),
                                      track = track or Track.objects.get(id=1),
                                      toProcess=self.q(0,0,0,track).count())
    self.progress.save()

  def run(self):
    self.minTile(0,0,0)
    self.progress.end()

  @staticmethod
  def q(z,x,y,track):
    bbox = Polygon.from_bbox((*tile_to_3857(z,x,y+1), *tile_to_3857(z,x+1,y)))
    bbox.srid = 3857
    q = Sounding.objects.filter(coord__coveredby=bbox)
    if track is not None:
      q = q.filter(track=track)
    return q

  def minTile(self,z,x,y):


    def printProg(z,x,y):
      print(' '*(150),end='\r')
      print('z=%d, x=%d, y=%d %s'%(z,x,y,self.progress),end='\r')

    with Perf() as p:
      pts = self.q(z,x,y,self.track)
    self.allLookup[z].add(p.t)

    if not pts.exists():
      return None

    # determine whether to recurse
    if z < self.MIN_RECURSE:
      recurse = True
    else:
      # if we are beyond MIN_RECURSE, but below max_recurse, go check how many points in total are contained
      # if fewer than MAX_POINTS, break the recursion
      if self.track is not None:
        pts = self.q(z,x,y,self.track)
      recurse = (z < self.max_recurse) and (pts.count() > self.MAX_POINTS)

    if recurse:
      pts = None # discard pts; we will not need this anymore
      c = [[2*x,2*y],[2*x+1,2*y],[2*x,2*y+1],[2*x+1,2*y+1]]

      # determine minimal sounding
      # XXX could smarten up when we update the database
      # we could also consider randomizing the order, such that we get more even progress
      minimal = None
      for xx,yy in c:
        r = self.minTile(z+1,xx,yy)
        if r is not None:
          if (minimal is None) or (r['z'] < minimal['z']):
            minimal = r

    else:
      self.progress.incProgress(pts.count())
      with Perf() as p:
        minimal = pts.annotate(mz=Min('z')).filter(mz=F('z')).values('id','z')[0]
      self.oneLookup[z].add(p.t)

      with Perf() as p:
        pts.exclude(min_level=z+1).update(min_level=z+1)
      self.allUpdate[z].add(p.t)

    # we now have minimal
    with Perf() as p:
      Sounding.objects.filter(id=minimal['id']).exclude(min_level=z).update(min_level=z)
    self.oneUpdate[z].add(p.t)
    # we could stop the updating here -- if no change, or rather -- change here increases the min_level

    if z == 14:
      printProg(z,x,y)

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

def simplifyFull(max_level,track=None):
  simplifier = HierachicalSimplifier(max_level,track)
  simplifier.run()

  printStat('all-search', simplifier.allLookup)
  printStat('min-search', simplifier.oneLookup)
  printStat('all-update', simplifier.allUpdate)
  printStat('one-update', simplifier.oneUpdate)

if __name__ == "__main__":
  parser = argparse.ArgumentParser(description='Process soundings to limit number of soundings per tile.')
  parser.add_argument('-f', '--force', dest='force', action='store_true',
                      help='process track even if it has already been processed')
  parser.add_argument('-m', '--maxlevel', dest='maxlev', action='store', type=int, default=Sounding.MAX_LEVEL,
                      help='maximum level')
  parser.add_argument('tracks', metavar='i', type=int, nargs='*',
                    help='a list of tracks to process. Leave empty for all tracks.')

  args = parser.parse_args()

  if len(args.tracks) == 0:
    logger.info("simplify all")
    with Perf() as p:
      simplifyFull(args.maxlev)
    logger.info("\nsimplification took %f s",p.t)
  else:

    tracks = Track.objects.filter(id__in=args.tracks).exclude(sounding=None)
    if not args.force:
      tracks = tracks.annotate(minlev=Min('sounding__min_level')).exclude(minlev__lt=Sounding.MAX_LEVEL+1)

    for track in tracks:
      logger.info("simplifying track %s",str(track))
      with Perf() as p:
        simplifyFull(args.maxlev, track)
      logger.info("\nsimplification took %f s",p.t)
