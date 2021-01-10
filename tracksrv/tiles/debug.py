"""
tile views for debug purposes
"""

import io
import threading
import numpy as np

#from scipy.interpolate import griddata

from scipy.spatial import Delaunay

from matplotlib.figure import Figure
from matplotlib.axes   import Axes
#from matplotlib.colors import Normalize, ListedColormap


tileLock = threading.Lock()

EQUATOR = 40075016.68557849

def tile_to_3857(z,x,y):
  tpz = 2**z
  x =  x/tpz*EQUATOR - EQUATOR/2
  y = -y/tpz*EQUATOR + EQUATOR/2
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

def points(z,xi,yi,pts,depth,res=256,fmt='png'):
  """
  return a tile with the points
  """

  # protect against multiple threads running in here
  with tileLock:

    fig,ax = setup_fig_ax(z,xi,yi)
    ax.scatter(pts[:,0], pts[:,1], c=depth, edgecolors=None, marker = ".", s=0.1)
    return get_figcontents(fig,res,fmt)

def delaunay(z,xi,yi,pts,depth,res=256,fmt='png'):
  """
  return a tile with the points
  """

  if len(pts)<3:
    raise Http404("empty tile")

  # protect against multiple threads running in here
  with tileLock:

    fig,ax = setup_fig_ax(z,xi,yi)
    tri = Delaunay(pts)
#    print("delaunay(%s)=%s"%(pts,tri.simplices))
    ax.triplot(pts[:,0], pts[:,1], tri.simplices,linewidth=0.05)
    return get_figcontents(fig,res,fmt)

