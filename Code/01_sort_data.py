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

import mammals_funcs as mf

################################################################################
# reading in general data: plot locations, fractal nesting, above-ground biomass
################################################################################

print("\nReading in plot and trap location data")

# open plot locations
with open('../Data/rows.geojson') as f:
    data = json.load(f)

properties = pd.DataFrame()

# add each line of geojson file to dataframe
for i in range(0, len(data['features'])):
    properties = properties.append(pd.DataFrame(data['features'][i]['properties'], index = [i]))

# only really care about these columns
properties = properties.loc[: , ["plot_size",
                                 "centroid_y",
                                 "centroid_x",
                                 "fractal_order",
                                 "location"]]

properties.rename(columns={'centroid_y':'longitude', 'centroid_x':'latitude'}, inplace=True)
properties["longlat"] = properties.apply(lambda x: [x.longitude, x.latitude], axis=1)

# seperate dataframe for only second order fractal points
second_order = properties.loc[properties.fractal_order == 2, : ]

# fractal nesting and agb data
fpn = pd.read_csv("../Data/Fractal_point_nesting.csv")
agb = pd.read_csv("../Data/AGB.csv")

fpn["FirstOrder"] = fpn.FirstOrder.str.partition("_")[2].astype(int)
fpn.columns = ["site",
               "habitat",
               "logging",
               "frag_area",
               "first_order",
               "second_order",
               "third_order",
               "fourth_order",
               "fifth_order"]
fractals = fpn.loc[:, ["site", "first_order", "second_order"]]

print("\nReading in aboveground biomass data")
# specific wanted columns - and rename ***(going with Chave moist)***
agb = agb[["field_name", "Plot", "Date", "AGB_Chave_moist", "ForestQuality"]]
agb.columns = ["field_name", "second_order", "date", "agb", "forestquality"]


################################################################################
# sort species data
################################################################################

import mammals_funcs as mf

print("\nReading in mammals data")
# open each seperate plot
E      = pd.read_csv("../Data/small_mammals/test/E_test.csv")
F      = pd.read_csv("../Data/small_mammals/test/F_test.csv")
D      = pd.read_csv("../Data/small_mammals/test/D_test.csv")
OG     = pd.read_csv("../Data/small_mammals/test/OG_test.csv")

# mammals species lookup table
m_lkup         = pd.read_csv("../Data/small_mammals/mammals_lookup.csv")
m_lkup.columns = ["code", "species", "scientific"]

# sort mammals data

print("\nSort mammals data")
mamls_df = mf.sort_mams_all(E, F, D, OG)
print("\nMerge with lookup to get scientific names")
mamls_df = mf.lkup_merge(mamls_df, m_lkup)
print("\nFind the closest fractal order to the trap location")
mamls_df = mf.closest_trap(mamls_df, properties, second_order)
print("\nMerge the aboveground biomass data")
mamls_df = mf.merge_agb(mamls_df, agb)
print("\nFinal cleanup and save mammals data")
mamls_df = mf.cleanup(mamls_df)
