#!/usr/bin/env python3

"""
Script:      sort_data.py
Author:      David Bridgwood
Description: """

__author__ = 'David Bridgwood (dmb2417@ic.ac.uk)'

# imports
import pandas as pd
import numpy as np

tree_df = pd.read_csv("../Results/trees_sorted.csv")

################################################################################
#calculating subplot level summaries for axis
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
    hgtvar = np.var(group.height)
    tbiomc = np.sum(group.stem_C + group.root_C)    # total biomass
    biovar = np.var(group.stem_C + group.root_C)
    simpdv = simpsonsdiv(group)                     # simpsons diversity
    return avghgt, tbiomc, simpdv, hgtvar, biovar

spsum = tree_df.groupby(['plot', 'subplot', 'census']).apply(sumstats).reset_index()

# add f_type in
spsum = spsum.merge(tree_df[["f_type", "plot"]].drop_duplicates(), how = 'left', on = 'plot')

# split up the statistics to individual columnes
spsum['avghgt'] = spsum.apply(lambda x: x[0][0], axis = 1)
spsum['tbiomc'] = spsum.apply(lambda x: x[0][1], axis = 1)
spsum['simpdv'] = spsum.apply(lambda x: x[0][2], axis = 1)
spsum['hgtvar'] = spsum.apply(lambda x: x[0][2], axis = 1)
spsum['biovar'] = spsum.apply(lambda x: x[0][2], axis = 1)

spsum.simpdv = spsum.simpdv.fillna(0)               # replace Nan simpsons with 0

spsum = spsum.drop([0], axis = 1)                   # drop to useless column

spsum['avghgtnorm'] =  ((spsum['avghgt'] - min(spsum['avghgt']))/
                        (max(spsum['avghgt'] - min(spsum['avghgt']))))

spsum['tbiomcnorm'] =  ((spsum['tbiomc'] - min(spsum['tbiomc']))/
                        (max(spsum['tbiomc'] - min(spsum['tbiomc']))))


spsum.to_csv("../Results/tree_axis.csv")            # save to csv
