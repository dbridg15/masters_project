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


mammal_df['Plot']     = mammal_df.apply(lambda row: row['Trap_ID'].split("-")[0], axis = 1)
mammal_df['Sub_Plot'] = mammal_df.apply(lambda row: row['Trap_ID'].split("-")[1], axis = 1)
mammal_df['Trap_no']  = mammal_df.apply(lambda row: row['Trap_ID'].split("-")[2], axis = 1)

mammal_df['Year']     = mammal_df.apply(lambda row: row['Occasion'].split("-")[2], axis = 1)
mammal_df['repeat']   = mammal_df.apply(lambda row: row['Occasion'].split("-")[3], axis = 1)


mammal_df.to_csv("../Results/mammals_sorted.csv", index = False)


species_plt_matrix = mammal_df.groupby(['Occasion', 'Species']).size().unstack()

species_plt_matrix.to_csv("../Results/mammals_matrix.csv")

