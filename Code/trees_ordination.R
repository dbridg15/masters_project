#!usr/bin/env Rscript

# script: test_PCA.R 
# Desc:   
# Author: David Bridgwood (dmb2417@ic.ac.uk)

# require
require(vegan)
require(hypervolume)

# TODO
#   *How to compare differnt censuses? - does NDMS need to be done with each
#    plot ar each census being a different 'sample'?
#
#   *Is hypervolume_svm the correct method?
#
#   *Still not really sure about how ordination is working/whether it is what I
#    should be doing...


###############################################################################
#
###############################################################################

# takes dataframe and returns count matrix
count_matrix <- function(df){
  df[is.na(df)] <- 0
  df <- as.matrix(df)
  return(df)
}

# takes dataframe and returns relative abundance matrix
rel_abnd <- function(df){
  df <- count_matrix(df)
  df <- t(apply(df, 1, function(x) x/sum(x)))
  return(df)
}

# read in species count matrix for each census
tree_df <- read.csv("../Results/trees_matrix.csv", header=T, row.names=1)
tree_cm <- count_matrix(tree_df)
tree_am <- rel_abnd(tree_df)

# NMDS on relative abundance matrix
# ***NOT SURE THIS IS RIGHT AS NOW THE DIFFERENT CENSUS' ARE NOT COMPARABLE***
# count_mds <- metaMDS(tree_cm, k = 3, trymax = 100)
# relab_mds <- metaMDS(tree_am, k = 3, trymax = 100)
# save(count_mds, relab_mds, file = "../Results/mds_out.Rdata")

load("../Results/mds_out.Rdata")
