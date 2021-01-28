"""
utility functions
"""

import io
import threading
import time

from matplotlib.figure import Figure
from matplotlib.axes   import Axes

tileLock = threading.Lock()

EQUATOR = 40075016.68557849

def tile_to_3857(z,x,y):
  tpz = 2**z
  m = EQUATOR / tpz
  x =  x*m - EQUATOR/2
  y = -y*m + EQUATOR/2
  return x,y

def setup_fig_ax(z,xi,yi):
  fig = Figure(figsize=[1.,1.],frameon=False)
  ax = Axes(fig, [0,0,1,1],frameon=False,clip_on=True)
  ax.set_axis_off()
  ax.set_autoscale_on(False)
  x0,y0,x1,y1 = *tile_to_3857(z,xi,yi),*tile_to_3857(z,xi+1,yi+1)
  ax.set_xbound(x0,x1)
  ax.set_ybound(y0,y1)
  fig.add_axes(ax)
  return fig,ax

def get_figcontents(fig,res,fmt):
  output = io.BytesIO()
  fig.savefig(output,pad_inches=0,bbox_inches='tight',dpi=res,transparent=True,format=fmt)
  contents = output.getvalue()
  output.close()
  return contents

class Perf():
    def __init__(self):
        self.start = time.time()

    def done(self):
        return time.time()-self.start

class NoTile(Exception):
  pass
