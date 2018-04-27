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
tree_df = pd.read_csv("../Data/SAFE_CarbonPlots_Tree+LianaCensus.csv")

def sort_data(df, census_no):  # give new column names, delete NAs and dead...

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
    df.columns = new_Cnames

    # get unique ID - combine plot and tag_no
    df = df.assign(ID = df['plot'] + df['tag_no'].map(str))

    # column with census number
    df = df.assign(census = census_no)

    # delete rows with NaNs in important columns
    impt_cols = ['tag_no', 'd_pom', 'h_pom', 'height', 'flag', 'alive',
                 'stem_C', 'root_C']

    df = df.dropna(subset = impt_cols, how = 'all')

    # delete dead trees (alive == 0)
    df = df[df.alive == 1]

    return df


# subset for each census
census_1 = tree_df.iloc[ :, list(range(0, 3))     # same for all
                          + list(range(3, 15))    # specific for census
                          + list(range(53, 62))]  # same for all

census_2 = tree_df.iloc[ :, list(range(0, 3))
                          + list(range(15, 27))
                          + list(range(53, 62))]

census_3 = tree_df.iloc[ :, list(range(0, 3))
                          + list(range(27, 39))
                          + list(range(53, 62))]

census_4 = tree_df.iloc[ :, list(range(0, 3))
                          + list(range(39, 51))
                          + list(range(53, 62))]

# sort data for each census
census_1 = sort_data(census_1, 1)
census_2 = sort_data(census_2, 2)
census_3 = sort_data(census_3, 3)
census_4 = sort_data(census_4, 4)

# recombine all census data (stack on top of each other)
frames = [census_1, census_2, census_3, census_4]

tree_df = pd.concat(frames)

# add genus column
tree_df['plot']      = tree_df['plot'].replace(" ", "", regex=True)
tree_df['genus']     = tree_df.apply(lambda row: row.binomial.split(" ")[0], axis = 1)
tree_df['subplotx']  = tree_df['plot'] + "_sp" + tree_df['subplot'].astype(str)
tree_df['subplotxc'] = tree_df['subplotx'] + "_c" + tree_df['census'].astype(str)

# save to csv
tree_df.to_csv("../Results/trees_sorted.csv", index = False)


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

spsum = tree_df.groupby(['plot', 'subplot', 'census']).apply(sumstats).reset_index()

# add f_type in
spsum = spsum.merge(tree_df[["f_type", "plot"]].drop_duplicates(), how = 'left', on = 'plot')

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

species_plt_matrix = tree_df.groupby(['subplotxc', 'binomial']).size().unstack()

species_plt_matrix.to_csv("../Results/trees_matrix.csv")
