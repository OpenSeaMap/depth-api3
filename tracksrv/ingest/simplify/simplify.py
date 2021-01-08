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

from django.contrib.gis.geos import Point

from django.contrib.gis.measure import Distance

from tracks.models import Track,Sounding

import tiles.transform as tf

#def mask2idx(mask):
#    return [i for i in range(len(mask)) if mask[i]]

def pd2md(z,lon,lat,pd):
  """
  convert distance in tile pixels to distance in meters, at location lat/lon and zoom level z.
  
  This is appoximate since horizontal and vertical distances vary across the tile.
  """

  from django.contrib.gis.geos import GEOSGeometry

  tpz = 2**z
  x = tf.lon2x(tpz,lon)
  y = tf.lat2y(tpz,lat)

  p  = GEOSGeometry('SRID=4326;POINT(%f %f)'%(lon,lat))
  p1 = GEOSGeometry('SRID=4326;POINT(%f %f)'%(tf.x2lon(tpz,x+pd),lat))
  p2 = GEOSGeometry('SRID=4326;POINT(%f %f)'%(lon,tf.y2lat(tpz,y+pd)))

  return 0.5*(p.distance(p1)+p.distance(p2)) * 100

def simplify(track,grid=256):
  """simplifyTrack(track,grid)

  track: the track to simplify
  grid: the resolution (?)
  get all points from the track. Then for every level between maxlevel and 0,
  and all tiles that the track traverses, start with the first point in this tile and keep it
  then search the first point that is further than one pixel, keep that,
  aso
  """

  # start out with all points in zoom level 1014
  print("Preparing soundings")
  Sounding.objects.filter(track=track).update(min_level=1014)
  for l in range(1014,1000+Sounding.MAX_LEVEL):
    print("LEVEL %d"%(l-1000))

    # find all track points at this or lower zoom levels
    while True:
      print ("working on level %d"%(l-1000))
      pts = Sounding.objects.filter(track=track,min_level__lte=1000+l)
      print ("working on level %d, points left: %d"%(l-1000,pts.count()))

      if pts.count() == 0: # if no more points at this level, go to next level
        break

#    pts_d = pts.annotate(d=Func(F('coord'),function='ST_Z'))

    # determine the shallowest point
#    shallow_level = pts_d.aggregate(Min('d'))

 #   print('random result: %s'%(str()))

#    print("shallowest level: %f"%(shallow_level))

#    shallow_pt = pts_d.filter(d=shallow_level)[0]

      shallow_pt_qry = pts.raw("""
        WITH shallow_d AS (
          SELECT min(ST_Z(coord)) FROM tracks_sounding WHERE min_level <= %(l)s AND track_id = %(id)s
        ) SELECT id FROM tracks_sounding
          WHERE ST_Z(coord)=(SELECT min FROM shallow_d) AND min_level <= %(l)s AND track_id = %(id)s
      """,{'l':1000+l,'id':track.id})
      if len(shallow_pt_qry) == 0: # if no more points at this level, go to next level
        print("out of points, unexpectedly")
        break

      shallow_pt = shallow_pt_qry[0]

      print("shallowest point: %s"%str(shallow_pt))
      print("shallowest level: %f"%(shallow_pt.coord.z))

      # if it is still in the temp levels, move it into zoom level l
      if shallow_pt.min_level >= 1000:
        shallow_pt.min_level = l

      r = Distance(km=1000*pd2md(l-1000,shallow_pt.coord.x,shallow_pt.coord.y,1.0/grid))
      print("minDist = %f [m]"%(r.km*1000))

      # move all points within radius r into the next level
      print("filtering away objects")
      Sounding.objects.filter(coord__distance_lt=(shallow_pt.coord, r)).update(min_level=1000+1+l)
      print("done")

if __name__ == "__main__":
  print("Simplify")
  for track in Track.objects.all():#.exclude(sounding__min_level__gte=Sounding.MAX_LEVEL):
    print(track)
    simplify(track, 256)
