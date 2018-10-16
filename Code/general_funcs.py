#!/usr/bin/env python3

"""
Author:      David Bridgwood (dmb2417@ic)
Description: """

__author__  = 'David Bridgwood (dmb2417@ic.ac.uk)'
__version__ = '0.0.1'

# imports
import pandas as pd
import numpy as np
import json

from geopy.distance import geodesic

################################################################################
# functions
################################################################################

# census_diff

def census_diff(df, census):
    """ calculate time difference between the middle points of consecutive
    censues and returns dataframe

    keyword arguments:
        df     -- dataframe with plot, date and census columns
        census -- string, the name of the census column in df"""

    grp               = df.groupby(["plot",  census])
    cen               = grp.date.agg(['min', 'max'])
    cen["mid"]        = (cen["min"] + (cen["max"] - cen["min"])/2).dt.date
    cen["difference"] = cen["mid"].diff().astype('timedelta64[D]')
    cen.loc[cen["difference"] < 0 , "difference"] = np.NAN
    cen["diff_yrs"] = cen.difference/365

    cen.reset_index(level = 0, inplace = True)
    cen.reset_index(level = 0, inplace = True)

    cen[census].astype(str)

    cen["step"] = cen[census].astype(str).shift() + "-" + cen[census].astype(str)
    cen.loc[cen["difference"].isnull(), "step"] = np.NaN
    cen.index = cen['plot'] + "_" + cen['step']

    return cen


# closest

def closest(pt, others):
    """ finds the closes point from others to point pt

    keyword arguments:
        pt     -- the specified point (long, lat)
        others -- list of points to find closest to pt (long, lat)"""

    clst_pt = min(others.longlat, key = lambda x: geodesic(pt, x).meters)
    distnce = geodesic(pt, clst_pt).meters
    clst_pt = others.location.loc[others.longlat.apply(lambda x: x == clst_pt)].reset_index(drop = True)

    return pd.Series([clst_pt.values[0], distnce])

