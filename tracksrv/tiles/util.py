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
  def __enter__(self):
    self.t = 0
    self.start = time.time()
    return self

  def __exit__(self, exc_type, exc_value, traceback):
    self.t = time.time()-self.start
    return False

class Stat():
  def __init__(self):
    self.n = 0
    self.c = 0
    self.c2 = 0

  def add(self,x):
    self.n += 1
    self.c += x
    self.c2 += x**2

  def cnt(self):
    return self.n
  def avg(self):
    if self.n == 0:
      return 0.
    else:
      return self.c / self.n
  def var(self):
    if self.n == 0:
      return 0.
    else:
      return self.c2 - self.c ** 2
class NoTile(Exception):
  pass
