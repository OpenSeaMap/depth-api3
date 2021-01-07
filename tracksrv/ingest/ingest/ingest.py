#!/usr/bin/python3

"""
looks for tracks where the format is known, and the track is not yet imported

each such track is imported
"""

import subprocess
import xml.etree.ElementTree as ET
from itertools import islice

import django
from django.contrib.gis.geos import Point
django.setup()


from tracks.models import Track,Sounding

def filter_GPX(track):

  """
  look for elements of the form
  <trkpt lon="11.13420161" lat="48.06410290" >
      <time>2000-01-16T13:16:01Z</time>
      <depth>2.32</depth>
      <watertemp>23.77</watertemp>
      <sog>0.66</sog>
  </trkpt>
  """

  f = track.rawfile

  inPt = False
  for event, elem in ET.iterparse(f,("start","end",)):
#    print("event %s tag=%s"%(event,elem.tag))

    if event == "start" and elem.tag == '{http://www.topografix.com/GPX/1/1}trkpt':
      try:
        lon,lat = float(elem.attrib['lon']),float(elem.attrib['lat'])
        inPt = True
      except:
        pass

    if elem.tag == '{http://www.topografix.com/GPX/1/1}depth':
      if inPt:
        try:
          d = float('0' + elem.text.lstrip().rstrip())

#          print("returning %f,%f,%f"%(lon,lat,d))
          yield (lon,lat,d)
#          cur.execute('INSERT INTO soundings (track_id,coord,depth,min_level) VALUES (%s,point(%s,%s),%s,%s)',(track_id,lon,lat,d,max_level+1))
        except:
          pass

    if event == "end" and elem.tag == '{http://www.topografix.com/GPX/1/1}trkpt':
      inPt = False

def ingest_GPX(track):

#  for c in filter_GPX(track):
#    print(c)
#    p = Point(*c)
#    print (p)

#  return 
  batch_size = 1000
  objs = (Sounding(track=track, coord=Point(c)) for c in filter_GPX(track))
  while True:
      batch = list(islice(objs, batch_size))
      if not batch:
          break
      Sounding.objects.bulk_create(batch, batch_size)

if __name__ == "__main__":
  for t in Track.objects.filter(format=Track.FileFormat.GPX):
    print(t)

    ingest_GPX(t)
