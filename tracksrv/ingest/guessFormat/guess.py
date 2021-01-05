#!/usr/bin/python3

import subprocess
import django
django.setup()

from tracks.models import Track

"""
guesses the format of a file
Supported formats:
  GPX
  NMEA0180
  NMEA0180 + OpenSeaMap timestamp
Optionally, also guess the compression format (gzip, zip) (not yet supported)
"""

for t in Track.objects.filter(processing_status=Track.ProcessingStatus.NEW):
  print(t)
  fn = str(t.rawfile)

  file_output = subprocess.run(['file','-m','ingest/guessFormat/.magic', fn], stdout=subprocess.PIPE, text=True)
  if 'GPX file with tracks containing points' in file_output.stdout:
    t.format = Track.FileFormat.GPX
  elif 'NMEA0183 with GNS RMS sentence' in file_output:
    if 'OSM time stamps' in file_output.stdout:
      t.format = Track.FileFormat.NMEA0183_OSM
    else:
      t.format = Track.FileFormat.NMEA0183

  print('format:{}'.format(t.format))
  t.save()
