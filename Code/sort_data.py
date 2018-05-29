#!/usr/bin/env python3

"""
Script:      sort_data.py
Author:      David Bridgwood
Description: """

__author__ = 'David Bridgwood (dmb2417@ic.ac.uk)'

# imports
import pandas as pd
import numpy as np

# TODO

################################################################################
# trees
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

# species matrix
tree_matrix = tree_df.groupby(['subplotxc', 'binomial']).size().unstack()

tree_matrix.to_csv("../Results/trees_matrix.csv")


################################################################################
# mammals
################################################################################

# readin RAW data
mammal_df = pd.read_csv("../Data/small_mammals.csv")

# consistant and better column names
new_Cnames = ['Occasion',
              'Date',
              'Trap_ID',
              'Species',
              'New/Return',
              'Tag_no',
              'Age',
              'Sex',
              'Sexing_Notes',
              'HF',
              'E',
              'AGD',
              'HB',
              'T',
              'Tail%HB',
              'MZ',
              'Bag_Weight(g)',
              'Gross_Weight',
              'Net_Weight',
              'Parasites',
              'Fat_Score',
              'Injuries',
              'Dead',
              'Tissue_Sample_ID',
              'Parasite_Sample_ID',
              'Fur_Sample_ID',
              'Feacal_Sample_1',
              'Feacal_Sample_2',
              'Processor',
              'Who_Baited?',
              'Flagged']

# give each census these column names
mammal_df.columns = new_Cnames

# get rid of question marks from sex - just go with what they thought...
mammal_df['Sex'] = mammal_df['Sex'].str.replace('?', "")
mammal_df['Occasion'] = mammal_df['Occasion'].str.replace('--', '-')
mammal_df['Trap_ID'] = mammal_df['Trap_ID'].str.replace('--', '-')


mammal_df['plot']     = mammal_df.apply(lambda row: row['Occasion'].split("-")[0], axis = 1)
mammal_df['sub_plot'] = mammal_df.apply(lambda row: row['Occasion'].split("-")[3], axis = 1)
mammal_df['trap_no']  = mammal_df.apply(lambda row: row['Trap_ID'].split("-")[2], axis = 1)

mammal_df['census']   = mammal_df.apply(lambda row: row['Occasion'].split("-")[2], axis = 1)
mammal_df['repeat']   = mammal_df.apply(lambda row: row['Occasion'].split("-")[1], axis = 1)  # not actually sure what this is...


mammal_df['subplotx'] = mammal_df['plot'] + "-" + mammal_df['repeat'].astype(str) + "_sp" + mammal_df['sub_plot'].astype(str)

mammal_df['subplotxc'] = mammal_df['subplotx'] + "_c" + mammal_df['census'].astype(str)

mammal_df.to_csv("../Results/mammals_sorted.csv", index = False)

# species matrix
mammal_matrix = mammal_df.groupby(['subplotxc', 'Species']).size().unstack()

mammal_matrix.to_csv("../Results/mammals_matrix.csv")


################################################################################
# beetles
################################################################################

# readin RAW data
beetle_df = pd.read_csv("../Data/family_list.csv")

# convert dates to datetime
beetle_df.date = pd.to_datetime(beetle_df.date, dayfirst = True)

# sampling periods
beetle_df['census'] = "incomplete"


def sample_period(df, s_date, e_date, period):
    df.loc[(df.date >= s_date) & (df.date < e_date), 'census'] = period

s1 = pd.to_datetime("01/01/2011", dayfirst = True)  # might be good to check!!
e1 = pd.to_datetime("01/04/2011", dayfirst = True)
s2 = pd.to_datetime("01/09/2011", dayfirst = True)
e2 = pd.to_datetime("01/01/2012", dayfirst = True)
s3 = pd.to_datetime("01/04/2012", dayfirst = True)
e3 = pd.to_datetime("01/09/2012", dayfirst = True)

sample_period(beetle_df, s1, e1, "P1")
sample_period(beetle_df, s2, e2, "P2")
sample_period(beetle_df, s3, e3, "P3")

beetle_df = beetle_df[beetle_df.census != "incomplete"]

beetle_df['block_trap_census'] = beetle_df.block + "_" + beetle_df.trap_N.astype(str) + "_" + beetle_df.census

beetle_df.to_csv("../Results/beetles_sorted.csv", index = False)


beetle_matrix = beetle_df.groupby(['block_trap_census', 'family']).size().unstack()

beetle_matrix.to_csv("../Results/beetles_matrix.csv")
