#!/usr/bin/python3

"""
looks for tracks where the format is known, and the track is not yet imported

each such track is imported
"""

import subprocess
import xml.etree.ElementTree as ET
from itertools import islice
import logging

logger = logging.getLogger(__name__)

import django
django.setup()

from django.db import connection
from django.contrib.gis.geos import Point
from django.core.mail import send_mail
from django.utils import timezone

import pynmea2

from tracks.models import Track,Sounding,ProcessingStatus

def progPrint(s):
  print('                                                                                    ',end='\r')
  print(s,end='\r')

def filter_CSV(f):
  """read in a CSV file, separated by semicolon.
  The first line needs to contain the column names "lat","lon","dbs","time" (in any order)
  i.e.
  lat;lon;dbs;time

  37.312124;26.56452829;5.35;2019-09-23 14:22:00.601
  37.312124;26.56452829;5.35;2019-09-23 14:22:00.601
  37.312124;26.56452829;5.35;2019-09-23 14:22:00.601

  empty lines are allowed; lines starting with "#" are ignored.
  """

  headers = None
  for line in f:
    line = line.rstrip()

    if len(line) == 0 or line[0] == '#':
      continue # ignore this line

    x = line.split(b';')
    if headers is None:
      logger.debug(x)
      if not(b'lat' in x and b'lon' in x and b'dbs' in x):
        logger.error('malformed header line in input file')
        raise ValueError

      headers = {}
      for i in range(len(x)):
        headers[x[i]] = i

      continue

    yield Point(float(x[headers[b'lon']]),float(x[headers[b'lat']]),srid=4326), float(x[headers[b'dbs']])

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
      if event == "start" and inPt:
        try:
          d = float('0' + elem.text.lstrip().rstrip())
          yield Point(lon,lat,srid=4326),d
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
          yield Point(lon,lat,srid=4326),float(msg.depth + msg.offset)
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

  ps = ProcessingStatus(name="ingest",track=track)
  ps.save()

  objs = (Sounding(track=track, coord=p.transform(3857,clone=True), z=z) for p,z in trkPts)
  while True:
      batch = list(islice(objs, BATCH_SIZE))
      if not batch:
          break
      Sounding.objects.bulk_create(batch, BATCH_SIZE)
      ps.incProgress(len(batch))
      progPrint(str(ps))

  ps.end()
  track.nPoints = ps.nProcessed
  track.save()

if __name__ == "__main__":

  if Track.objects.filter(sounding=None).exists():

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

    # drop all indices (except the primary) beforehand
    with connection.cursor() as cursor:
      logger.debug("dropping index")
      cursor.execute("""
        DROP INDEX tracks_sounding_z_8af7739d;
        DROP INDEX tracks_sounding_coord_id;
        DROP INDEX tracks_sounding_min_level_744b912d;
        DROP INDEX tracks_sounding_track_id_e77bcf1c;
      """)

    try:
      # all tracks that do not have any soundings yet
      for track in Track.objects.filter(sounding=None):
        logger.info("start ingest %s",str(track))

        if track.format == Track.FileFormat.GPX:
          it = filter_GPX(track.rawfile)
        elif track.format == Track.FileFormat.NMEA0183:
          it = filter_NMEA(track.rawfile,osm=False)
        elif track.format == Track.FileFormat.NMEA0183_OSM:
          it = filter_NMEA(track.rawfile,osm=True)
        elif track.format == Track.FileFormat.TAGGED_CSV:
          it = filter_CSV(track.rawfile)
        else:
          it = () # emtpy iterator -> no points

        do_ingest(track,it)
        if it != ():
          subject = 'Done ingesting {}'.format(str(track))
          body = """The track contained {} points
          """.format(Sounding.objects.filter(track=track).count())

          logger.info("done ingest track %s",str(track))
          try:
            send_mail(
              subject,body,
              'ingest@fermi.franken.de',       # FROM
              ['openseamap@fermi.franken.de'], # TO
              fail_silently=False,
            )
          except:
            pass

    finally:
      # re-create min_level index
      with connection.cursor() as cursor:
        logger.debug("recreating index")
        cursor.execute("""
          CREATE INDEX tracks_sounding_z_8af7739d ON tracks_sounding (z);
          CREATE INDEX tracks_sounding_coord_id ON tracks_sounding USING GIST (coord GIST_GEOMETRY_OPS_ND);
          CREATE INDEX tracks_sounding_track_id_e77bcf1c ON tracks_sounding (track_id);
          CREATE INDEX tracks_sounding_min_level_744b912d ON tracks_sounding (min_level);
          """)
