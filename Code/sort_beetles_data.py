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
beetle_df = pd.read_csv("../Data/family_list.csv")

# convert dates to datetime
beetle_df.date = pd.to_datetime(beetle_df.date, dayfirst = True)

# sampling periods
beetle_df['sample_period'] = "incomplete"


def sample_period(df, s_date, e_date, period):
    df.loc[(df.date >= s_date) & (df.date < e_date), 'sample_period'] = period

s1 = pd.to_datetime("01/01/2011", dayfirst = True)  # might be good to check!!
e1 = pd.to_datetime("01/04/2011", dayfirst = True)
s2 = pd.to_datetime("01/09/2011", dayfirst = True)
e2 = pd.to_datetime("01/01/2012", dayfirst = True)
s3 = pd.to_datetime("01/04/2012", dayfirst = True)
e3 = pd.to_datetime("01/09/2012", dayfirst = True)

sample_period(beetle_df, s1, e1, "P1")
sample_period(beetle_df, s2, e2, "P2")
sample_period(beetle_df, s3, e3, "P3")

beetle_df = beetle_df[beetle_df.sample_period != "incomplete"]

beetle_df['test'] = beetle_df.sample_period + "_" + beetle_df.block + "_" + beetle_df.trap_N.astype(str)

beetle_df.to_csv("../Results/beetles_sorted.csv", index = False)


species_plt_matrix = beetle_df.groupby(['test', 'family']).size().unstack()

species_plt_matrix.to_csv("../Results/beetles_matrix.csv")

