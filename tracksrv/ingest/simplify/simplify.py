#!/usr/bin/python3

"""
looks for tracks where all soundings of that track have the min_level set to MAX_LEVEL or beyond

each such track is then simplified
"""

import xml.etree.ElementTree as ET
from itertools import islice

import django
django.setup()

from django.db.models import Min, F, Func
from django.contrib.gis.geos import Point, GEOSGeometry, Polygon
from django.contrib.gis.measure import Distance

from tracks.models import Track,Sounding

import tiles.transform as tf
from tiles.util import tile_to_3857

SUBDIV = 2

def recurseDown(z,x,y):
  """ starting with 0,0,0, if there is a point in the tile, recurse

    if we are at the lowest level, find the shallowest point and enter it z+subdiv levels higher
  """

  if z == 15:
    print()
    print("LEVEL %d tile %d,%d"%(z,x,y))

  bbox = Polygon.from_bbox((*tile_to_3857(z,x,y+1), *tile_to_3857(z,x+1,y)))
  bbox.srid = 3857

  pts = Sounding.objects.filter(coord__contained=bbox)
#  print(pts.query)

  if pts.count():
#    print("%d points in box"%(pts.count()))

    if z == Sounding.MAX_LEVEL+SUBDIV:
#      print("select shallowest direct")
      pts.update(min_level=Sounding.MAX_LEVEL+1)
      if z >= 15:
        print(".",end="")
      pass
      # simply select the shallowest of all points in this tile
    else:
      # else recurse
      pts = [recurseDown(z+1,2*x,2*y),  recurseDown(z+1,2*x+1,2*y),
             recurseDown(z+1,2*x,2*y+1),recurseDown(z+1,2*x+1,2*y+1)]
      if z >= 15:
        print("+",end="")

    if z >= SUBDIV:
      for p_min in pts:
        if p_min is not None: break

      d_min = p_min.coord.z
      for p in pts:
        if p is not None and p.coord.z < d_min:
          d_min,p_min = p.coord.z,p

      p_min.min_level = z-SUBDIV
      p_min.save()

      return p_min

  return None

def simplify(track,grid):
#  Sounding.objects.filter(track=track).update(min_level=Sounding.MAX_LEVEL+1)
  recurseDown(0,0,0)

if __name__ == "__main__":
  print("Simplify")
  for track in Track.objects.exclude(sounding=None):
    print(track)
    simplify(track, 256)
