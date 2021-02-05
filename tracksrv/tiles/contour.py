import io
import threading
import numpy as np

from scipy.interpolate import griddata

from matplotlib.figure import Figure
from matplotlib.axes   import Axes
from matplotlib.colors import Normalize, ListedColormap

"""
We want to map depth measurements to colors. 

    0-1 m dark blau (0.47,0.67,0.90)
    1-4 m medium blue (0.6,0.80,1)
    4-6 m light blue (0.8,1,1)
    6+ m white
    for reference: land -- ffffcc, buildings: e4e4b1

0   1   4   6  50

 B3  B2  B1  WHT  (transparent below 50 m)

0   1   2   3   4
0  .25 .50 .75  1
"""
# a standard colorscheme for the depths
std_chart_colors = {"levels":(0,1,4,6,50), "colors": ((0.47,0.67,0.9), (0.6,0.8,1.0), (0.8,1.0,1.0), (1.0,1.0,1.0))}

class seabed_norm(Normalize):
    """Normalization of depth values into sea bed colormap

    """
    def __init__(self,levels):
        Normalize.__init__(self)
        self.x,self.y = levels,np.linspace(0,1,num=len(levels))

    def __call__(self,value,clip=None):
        return np.ma.masked_array(np.interp(value,self.x,self.y))

from tiles.util import NoTile, tile_to_3857, setup_fig_ax, get_figcontents, tileLock

def tile(z,xi,yi,c_tile,depth,res=256,fmt='png',colormap=True,soundings=None,isolines=None,color_scheme=std_chart_colors):
  """return a graphics file with contour lines
  z -- zoom
  x,y -- tile coordinates
  res=256,fmt='png',colormap=False,soundings=True,isolines=True,color_scheme=std_chart_colors
  """

  if len(c_tile)<3:
    raise NoTile

  if soundings is None:
    soundings = (z>=14)
  if isolines is None:
    isolines = (z>=12)

  # controls quality: higher = better. No need to set higher than res/2
  subdiv = 128

  # protect against multiple threads running in here
  with tileLock:
    fig,ax = setup_fig_ax(z,xi,yi)

    cm_seabed = ListedColormap(color_scheme["colors"])
    sn = seabed_norm(color_scheme["levels"])

    if colormap or isolines:

        x0,y0,x1,y1 = *tile_to_3857(z,xi,yi),*tile_to_3857(z,xi+1,yi+1)
        xs, ys = np.mgrid[x0:x1:subdiv*1j, y0:y1:subdiv*1j]

        grid_d = griddata(c_tile, depth, (xs,ys), method='linear')

        if colormap:
            cset = ax.contourf(xs, ys, grid_d, levels=color_scheme["levels"], cmap=cm_seabed, norm=sn),

        if isolines:

            # start with non-labeled contour/s
            ax.contour(xs, ys, grid_d, levels=(5,15,),colors='b',linewidths=0.25),

            # then, labeled contours
            ax.clabel(
                ax.contour(xs, ys, grid_d, levels=(3,10,20,30),colors='b',linewidths=0.25),
            inline=1, fontsize=5, fmt="%1.0f")

    return get_figcontents(fig,res,fmt)
