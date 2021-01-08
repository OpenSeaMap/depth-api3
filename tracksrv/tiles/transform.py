import math

def y2lat(tpz,y):
    """Convert from tile pixel y coordinates to latitude in degrees.
    tpz -- 2**zoom
    y -- vertical coordinate (between 0 and tpz)
    """
    lat_rad = math.atan(math.sinh(math.pi * (1-2*(y/tpz))))
    lat_deg = math.degrees(lat_rad)
    return lat_deg

def lat2y(tpz,lat):
    """Convert from latitude in degrees to vertical tile pixel y coordinates.
    tpz -- 2**zoom
    lat -- latitude in degrees

    The return value is contained in the interval [0; tpz[ and increases
     from North to South
    """
    lat_rad = math.radians(lat)
    return tpz*(1-math.asinh(math.tan(lat_rad))/math.pi)/2.

def x2lon(tpz,x):
    """Convert from tile pixel x coordinates to longitude in degrees.
    tpz -- 2**zoom
    x -- horizontal coordinate (between 0 and tpz)
    """
    return (x/tpz)*360-180

def lon2x(tpz,lon):
    """Convert from longitude in degrees to horizontal tile pixel coordinates.
    tpz -- 2**zoom
    lon -- longitude in degrees
    The return value is contained in the interval [0; tpz[ and increases
     from West to East. 0 is at the date line.
    """
    return tpz*(lon+180)/360.
