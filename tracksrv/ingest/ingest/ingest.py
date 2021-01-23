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
from django.core.mail import send_mail

import pynmea2


from tracks.models import Track,Sounding

def filter_GPX(f):

  """
  look for elements of the form
  <trkpt lon="11.13420161" lat="48.06410290" >
      <time>2000-01-16T13:16:01Z</time>
      <depth>2.32</depth>
      <watertemp>23.77</watertemp>
      <sog>0.66</sog>
  </trkpt>
  """

  inPt = False
  for event, elem in ET.iterparse(f,("start","end",)):

    if elem.tag == '{http://www.topografix.com/GPX/1/1}trkpt':
      if event == "start":
        try:
          lon,lat = float(elem.attrib['lon']),float(elem.attrib['lat'])
          inPt = True
        except:
          pass
      elif event == "end":
        inPt = False

    elif elem.tag == '{http://www.topografix.com/GPX/1/1}depth':
      if inPt:
        try:
          d = float('0' + elem.text.lstrip().rstrip())
          yield Point(lon,lat,d,srid=4326)
        except:
          pass

def filter_NMEA(f,osm=True):
  last_seen_time = None

  for line in f.readlines():
    if osm:
      # skip first 15 bytes -- OSM logger preprends every line with a timestamp
      # XXX TODO make use of timestamp
      line = line[15:]
    try:
      msg = pynmea2.parse(line.decode('utf-8'))
      if msg.sentence_type == 'GGA': # position and time
        if msg.is_valid:
          # record last time and position, and merge them with the next DPT measurement
          last_seen_time = msg.timestamp
          lon,lat = msg.longitude,msg.latitude
        else:
#          logger.debug('found invalid GGA message')
          pass
      elif msg.sentence_type == 'DPT': # depth transducer
        if msg.depth is not None:
          yield Point(lon,lat,float(msg.depth + msg.offset),srid=4326)
        else:
#         logger.debug('found invalid DPT message')
          pass
    except (AttributeError,NameError) as e:
      # ignore these as apparently no message recognition can be done without them
      pass
    except pynmea2.ParseError as e: # ignore all parse errors
#      logger.debug('Parse error: {%s}',e)
      pass
    except (UnicodeDecodeError) as e: # report these but otherwise also ignore
#      logger.debug('unicode error: {%s}',e)
      pass

def do_ingest(track,trkPts):
  # to avoid holding several million points in memory, add the points in batches of 10000
  BATCH_SIZE = 10000

  objs = (Sounding(track=track, coord=p.transform(3857,clone=True)) for p in trkPts)
  while True:
      batch = list(islice(objs, BATCH_SIZE))
      if not batch:
          break
      Sounding.objects.bulk_create(batch, BATCH_SIZE)

if __name__ == "__main__":

  try:
    send_mail(
      'Ingest is starting',
      'The ingest process has started.',
      'ingest@fermi.franken.de',       # FROM
      ['openseamap@fermi.franken.de'], # TO
      fail_silently=False,
    )
  except:
    pass

  # all tracks that do not have any soundings yet
  for track in Track.objects.filter(sounding=None):
    print(track)
    if track.format == Track.FileFormat.GPX:
      it = filter_GPX(track.rawfile)
    elif track.format == Track.FileFormat.NMEA0183:
      it = filter_NMEA(track.rawfile,osm=False)
    elif track.format == Track.FileFormat.NMEA0183_OSM:
      it = filter_NMEA(track.rawfile,osm=True)
    else:
      it = () # emtpy iterator -> no points
    do_ingest(track,it)
    if it != ():
      subject = 'Done ingesting {}'.format(str(track))
      body = """The track contained {} points
      """.format(track.npoints)

      try:
        send_mail(
          subject,body,
          'ingest@fermi.franken.de',       # FROM
          ['openseamap@fermi.franken.de'], # TO
          fail_silently=False,
        )
      except:
        pass
