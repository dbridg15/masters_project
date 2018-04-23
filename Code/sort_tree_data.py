#!/usr/bin/env python3

"""
Script:      sort_tree_data.py
Author:      David Bridgwood
Description: """

__author__ = 'David Bridgwood (dmb2417@ic.ac.uk)'

# imports
import pandas as pd
import numpy as np

# TODO

################################################################################
#
################################################################################

# readin RAW data
df = pd.read_csv("../Data/SAFE_CarbonPlots_Tree+LianaCensus.csv")

# subset for each census
census_1 = df.iloc[ :, list(range(0, 3))     # same for all
                     + list(range(3, 15))    # specific for census
                     + list(range(53, 62))]  # same for all

census_2 = df.iloc[ :, list(range(0, 3))
                     + list(range(15, 27))
                     + list(range(53, 62))]

census_3 = df.iloc[ :, list(range(0, 3))
                     + list(range(27, 39))
                     + list(range(53, 62))]

census_4 = df.iloc[ :, list(range(0, 3))
                     + list(range(39, 51))
                     + list(range(53, 62))]

# consistant and better column names

new_Cnames = ['f_type',       # forest type
              'plot',
              'subplot',
              'date',         # date of measurements
              'observers',
              'tag_no',
              'd_pom',        # diameter of tree (cm)
              'h_pom',        # height diameter is taken (m) 1.3 by default
              'height',
              'flag',         # condition of trees (see flag list)
              'alive',        # 1 = yes, NaN = no
              'stem_C',       # aboveground biomass of tree (kg)
              'root_C',       # root biomass of tree
              'field_cmnts',  # comments from field
              'data_cmnts',   # comments from data entry
              'sbplt_X',
              'sbplt_Y',
              'CPA',          # projected area of the crown of the stem
              'X_FMC',        # plot level X coordinate
              'Y_FMC',        # plot level Y coordinte
              'Z_FMC',        # plot level elevation
              'family',
              'binomial',
              'wood_density']

# give each census these column names
census_1.columns = new_Cnames
census_2.columns = new_Cnames
census_3.columns = new_Cnames
census_4.columns = new_Cnames

# get unique ID - combine plot and tag_no
census_1 = census_1.assign(ID = census_1['plot'] + census_1['tag_no'].map(str))
census_2 = census_2.assign(ID = census_2['plot'] + census_2['tag_no'].map(str))
census_3 = census_3.assign(ID = census_3['plot'] + census_3['tag_no'].map(str))
census_4 = census_4.assign(ID = census_4['plot'] + census_4['tag_no'].map(str))

# column with census number
census_1 = census_1.assign(census = 1)
census_2 = census_2.assign(census = 2)
census_3 = census_3.assign(census = 3)
census_4 = census_4.assign(census = 4)

# delete rows with NaNs in important columns

impt_cols = ['tag_no', 'd_pom', 'h_pom', 'height', 'flag', 'alive', 'stem_C',
             'root_C']

census_1 = census_1.dropna(subset = impt_cols, how = 'all')
census_2 = census_2.dropna(subset = impt_cols, how = 'all')
census_3 = census_3.dropna(subset = impt_cols, how = 'all')
census_4 = census_4.dropna(subset = impt_cols, how = 'all')

# delete dead trees (alive == 0)
census_1 = census_1[census_1.alive == 1]
census_2 = census_2[census_2.alive == 1]
census_3 = census_3[census_3.alive == 1]
census_4 = census_4[census_4.alive == 1]


# recombine all census data (stack on top of each other)
frames = [census_1, census_2, census_3, census_4]

df = pd.concat(frames)

# add genus column
df['genus']    = df.apply(lambda row: row.binomial.split(" ")[0], axis = 1)
df['subplotx'] = df['plot'] + df['subplot'].astype(str)

# save to csv
df.to_csv("../Results/trees_sorted.csv", index = False)


################################################################################
# calculating subplot level summaries for axis
################################################################################

# simpsons diversity index
def simpsonsdiv(df):
    spccounts = df.groupby(['binomial']).apply(lambda x: len(x))
    numarator = np.nansum(spccounts*(spccounts - 1))
    denominator = len(df)*(len(df) - 1)
    return  1 - (numarator/denominator)

# summary stats for each subplot...
def sumstats(group):
    avghgt = np.mean(group.height)                  # average height
    tbiomc = np.sum(group.stem_C + group.root_C)    # total biomass
    simpdv = simpsonsdiv(group)                     # simpsons diversity
    return avghgt, tbiomc, simpdv

spsum = df.groupby(['plot', 'subplot', 'census']).apply(sumstats).reset_index()

# add f_type in
spsum = spsum.merge(df[["f_type", "plot"]].drop_duplicates(), how = 'left', on = 'plot')

# split up the statistics to individual columnes
spsum['avghgt'] = spsum.apply(lambda x: x[0][0], axis = 1)
spsum['tbiomc'] = spsum.apply(lambda x: x[0][1], axis = 1)
spsum['simpdv'] = spsum.apply(lambda x: x[0][2], axis = 1)

spsum.simpdv = spsum.simpdv.fillna(0)               # replace Nan simpsons with 0

spsum = spsum.drop([0], axis = 1)                   # drop to useless column

spsum['avghgtnorm'] =  ((spsum['avghgt'] - min(spsum['avghgt']))/
                        (max(spsum['avghgt'] - min(spsum['avghgt']))))

spsum['tbiomcnorm'] =  ((spsum['tbiomc'] - min(spsum['tbiomc']))/
                        (max(spsum['tbiomc'] - min(spsum['tbiomc']))))


spsum.to_csv("../Results/tree_axis.csv")            # save to csv


################################################################################
# species matrix
################################################################################

species_plot_matrix = df.groupby(['subplotx', 'binomial']).size().unstack()

species_plot_matrix.to_csv("../Results/trees_matrix.csv")

