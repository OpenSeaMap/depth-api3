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

from tiles.util import NoTile, tile_to_3857, setup_fig_ax, get_figcontents, tileLock

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
    raise NoTile

  # protect against multiple threads running in here
  with tileLock:

    fig,ax = setup_fig_ax(z,xi,yi)
    tri = Delaunay(pts)
#    print("delaunay(%s)=%s"%(pts,tri.simplices))
    ax.triplot(pts[:,0], pts[:,1], tri.simplices,linewidth=0.25,c='k')
    return get_figcontents(fig,res,fmt)
