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

    # sort out dates
    df.date = pd.to_datetime(df.date, dayfirst = True)

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
tree_df = pd.concat([census_1, census_2, census_3, census_4], ignore_index = True)

# add genus column
tree_df['plot']      = tree_df['plot'].replace(" ", "", regex=True)
tree_df['subplot']   = tree_df['subplot'].apply(lambda x: str(x).zfill(2))
tree_df['genus']     = tree_df.apply(lambda row: row.binomial.split(" ")[0], axis = 1)
tree_df['subplotx']  = tree_df['plot'] + "_sp" + tree_df['subplot'].astype(str)
tree_df['subplotxc'] = tree_df['subplotx'] + "_c" + tree_df['census'].astype(str)
tree_df['plot_c']    = tree_df['plot'] + "_c" + tree_df['census'].astype(str)
tree_df['census']    = "c" + tree_df.census.astype(str)

# save to csv
tree_df.to_csv("../Results/trees_sorted.csv", index = False)

# species matrix
tree_matrix = tree_df.groupby(['subplotxc', 'binomial']).size().unstack()
tree_matrix = tree_matrix.fillna(value = 0)
tree_matrix.to_csv("../Results/trees_matrix.csv")

tree_genus_matrix = tree_df.groupby(['subplotxc', 'genus']).size().unstack()
tree_genus_matrix = tree_genus_matrix.fillna(value = 0)
tree_genus_matrix.to_csv("../Results/trees_genus_matrix.csv")

tree_family_matrix = tree_df.groupby(['subplotxc', 'family']).size().unstack()
tree_family_matrix = tree_family_matrix.fillna(value = 0)
tree_family_matrix.to_csv("../Results/trees_family_matrix.csv")

################################################################################
# mammals
################################################################################

# readin RAW data
m_df   = pd.read_csv("../Data/small_mammals.csv")

m_lkup = pd.read_csv("../Data/RAW/small_mammals/mammals_lookup.csv")

# need to decide which one to use!
# PanTHERIA_WR05 = pd.read_csv("../Data/RAW/small_mammals/PanTHERIA/PanTHERIA_1-0_WR05_Aug2008.txt", sep = "\t")
PanTHERIA_WR93 = pd.read_csv("../Data/RAW/small_mammals/PanTHERIA/PanTHERIA_1-0_WR93_Aug2008.txt", sep = "\t")

PanTHERIA_WR93[PanTHERIA_WR93 == -999] = np.nan

EltonTraits = pd.read_csv("../Data/RAW/small_mammals/MamFuncDat.txt", sep = "\t")

# consistant and better column names
new_Cnames = ['Occasion',
              'date',
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
m_df.columns = new_Cnames

# get rid of question marks from sex - just go with what they thought...
m_df['Sex']       = m_df['Sex'].str.replace('?', "")
m_df['Occasion']  = m_df['Occasion'].str.replace('--', '-')
m_df['Trap_ID']   = m_df['Trap_ID'].str.replace('--', '-')

m_df['plot']      = m_df.apply(lambda row: row['Occasion'].split("-")[0], axis = 1)
m_df['sub_plot']  = m_df.apply(lambda row: row['Occasion'].split("-")[3], axis = 1)
m_df['trap_no']   = m_df.apply(lambda row: row['Trap_ID'].split("-")[2], axis = 1)

m_df['census']    = m_df.apply(lambda row: row['Occasion'].split("-")[2], axis = 1)
m_df['census']    = "c" + m_df.census.astype(str)
m_df['repeat']    = m_df.apply(lambda row: row['Occasion'].split("-")[1], axis = 1)  # not actually sure what this is...


m_df['subplotx']  = m_df['plot'] + "-" + m_df['repeat'].astype(str) + "_sp" + m_df['sub_plot'].astype(str)

m_df['subplotxc'] = m_df['subplotx'] + "_" + m_df['census'].astype(str)

m_df['plot']      =  m_df['plot'] + "-" + m_df['repeat'].astype(str)

# strip whitespace around Species codes
m_df.Species = m_df.Species.str.strip()

# if its a questionmark - I just go with it
# if its an either or I go with the first one!
m_df.loc[m_df.loc[:, "Species"] == "squirrel",     "Species"] = "unknown"
m_df.loc[m_df.loc[:, "Species"] == "SS?",          "Species"] = "SS"
m_df.loc[m_df.loc[:, "Species"] == "RS or SS" ,    "Species"] = "RS"
m_df.loc[m_df.loc[:, "Species"] == "WH or SS",     "Species"] = "WH"
m_df.loc[m_df.loc[:, "Species"] == "BS/RS?",       "Species"] = "BS"
m_df.loc[m_df.loc[:, "Species"] == "PTSQ?",        "Species"] = "PTSQ"
m_df.loc[m_df.loc[:, "Species"] == "LETRS",        "Species"] = "LETRS?"   # for some reason the lookup table has a ?
m_df.loc[m_df.loc[:, "Species"] == "CBS?",         "Species"] = "CBS"
m_df.loc[m_df.loc[:, "Species"] == "SL?TRS",       "Species"] = "SLTRS"
m_df.loc[m_df.loc[:, "Species"] == "SLTRS?",       "Species"] = "SLTRS"
m_df.loc[m_df.loc[:, "Species"] == "L?TRS",        "Species"] = "SLTRS"
m_df.loc[m_df.loc[:, "Species"] == "LSQ?",         "Species"] = "LSQ"
m_df.loc[m_df.loc[:, "Species"] == "LTRS or CTRS", "Species"] = "CTRS"     # went with CTRS as LTRS could refer to a couple
m_df.loc[m_df.loc[:, "Species"] == "LTRS",         "Species"] = "LETRS?"   # not convinced about this one
m_df.loc[m_df.loc[:, "Species"] == "squirrel",     "Species"] = "unknown"  # mmm?
m_df.loc[m_df.loc[:, "Species"] == "?",            "Species"] = "unknown"
m_df.loc[m_df.loc[:, "Species"] == "Unknown",      "Species"] = "unknown"

m_df.loc[pd.isna(m_df["Species"]), "Species"] = "unknown"

# species matrix
m_matrix = m_df.groupby(['subplotxc', 'Species']).size().unstack()
m_matrix = m_matrix.fillna(value = 0)
m_matrix.to_csv("../Results/mammals_matrix.csv")

# merge with lookup table
m_df = pd.merge(m_df, m_lkup, how = "left", left_on = "Species", right_on = "Code")

m_df.loc[pd.isnull(m_df.Scientific).nonzero()[0], "Scientific"] = "Unknown unknown"

m_df.loc[m_df.loc[:, "Scientific"] == "Calliosciurus adamsi" , "Scientific"] = "Callosciurus adamsi"
m_df.loc[m_df.loc[:, "Scientific"] == "Calliosciurus notatus", "Scientific"] = "Callosciurus notatus"

# merging with PanTHERIA database

m_df = pd.merge(m_df, PanTHERIA_WR93, how = "left", left_on = "Scientific", right_on = "MSW93_Binomial")

m_df = pd.merge(m_df, EltonTraits, how = "left", on = "Scientific")

m_df.to_csv("../Results/mammals_sorted.csv", index = False)

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

beetle_df["plot"] = beetle_df["block"]

beetle_df.to_csv("../Results/beetles_sorted.csv", index = False)


beetle_matrix = beetle_df.groupby(['block_trap_census', 'family']).size().unstack()
beetle_matrix = beetle_matrix.fillna(value = 0)
beetle_matrix.to_csv("../Results/beetles_matrix.csv")


################################################################################
# census time differences
################################################################################


def census_diff(df):

    df.date = pd.to_datetime(df.date)
    grp = df.groupby(["plot",  "census"])
    cen = grp.date.agg(['min', 'max'])
    cen["mid"] = (cen["min"] + (cen["max"] - cen["min"])/2).dt.date
    cen["difference"] = cen["mid"].diff().astype('timedelta64[D]')
    cen.loc[cen["difference"] < 0 , "difference"] = np.NAN
    cen["diff_yrs"] = cen.difference/365

    cen.reset_index(level=0, inplace=True)
    cen.reset_index(level=0, inplace=True)

    cen.census.astype(str)
    cen["step"] = cen.census.shift() + "-" + cen.census
    cen.loc[cen["difference"].isnull(), "step"] = np.NaN

    cen.index = cen['plot'] + "_" + cen['step']

    return cen


trees_cen = census_diff(tree_df)
mamls_cen = census_diff(m_df)
btles_cen = census_diff(beetle_df)

trees_cen.to_csv("../Results/trees_census_dates.csv")
mamls_cen.to_csv("../Results/mammals_census_dates.csv")
btles_cen.to_csv("../Results/beetles_census_dates.csv")
