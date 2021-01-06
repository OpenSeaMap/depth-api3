#!/usr/bin/python3

"""
guesses the format of a file
Supported formats:
  GPX
  NMEA0180
  NMEA0180 + OpenSeaMap timestamp
Optionally, also guess the compression format (gzip, zip) (not yet supported)
"""

import subprocess
import xml.etree.ElementTree as ET

import django
django.setup()

from tracks.models import Track

def ingest_GPX(track):
  """
  look for elements of the form
  <trkpt lon="11.13420161" lat="48.06410290" >
      <time>2000-01-16T13:16:01Z</time>
      <depth>2.32</depth>
      <watertemp>23.77</watertemp>
      <sog>0.66</sog>
  </trkpt>
  """

  nSoundings = 0
  for event, elem in ET.iterparse(track.rawfile,("start","end",)):

    if event == "start" and elem.tag == '{http://www.topografix.com/GPX/1/1}trkpt':
      try:
        lat,lon = elem.attrib['lat'],elem.attrib['lon']
        inPt = True
      except:
        pass

    if elem.tag == '{http://www.topografix.com/GPX/1/1}depth':
      if inPt:
        try:
          d = float('0' + elem.text.lstrip().rstrip())
#          cur.execute('INSERT INTO soundings (track_id,coord,depth,min_level) VALUES (%s,point(%s,%s),%s,%s)',(track_id,lon,lat,d,max_level+1))
          nSoundings += 1
        except:
          pass

    if event == "end" and elem.tag == '{http://www.topografix.com/GPX/1/1}trkpt':
      inPt = False
  return nSoundings

for t in Track.objects.filter(format=Track.FileFormat.GPX):
  print(t)

  ingest_GPX(t)

