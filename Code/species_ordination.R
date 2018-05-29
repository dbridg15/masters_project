#!usr/bin/env Rscript

# script: test_PCA.R 
# Desc:   
# Author: David Bridgwood (dmb2417@ic.ac.uk)

# require
require(vegan)
require(hypervolume)

set.seed(123)

# TODO
#   *How to compare differnt censuses? - does NDMS need to be done with each
#    plot ar each census being a different 'sample'?
#
#   *Still not really sure about how ordination is working/whether it is what I
#    should be doing...


###############################################################################
# functions
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

###############################################################################
# the ordination
###############################################################################

# read in species count matrix for each census
tree_df <- read.csv("../Results/trees_matrix.csv", header=T, row.names=1)
tree_cm <- count_matrix(tree_df)
tree_am <- rel_abnd(tree_df)

# NMDS on relative abundance matrix
# ***NOT SURE THIS IS RIGHT AS NOW THE DIFFERENT CENSUS' ARE NOT COMPARABLE***
tree_count_mds <- metaMDS(tree_cm, k = 3, trymax = 100)
tree_relab_mds <- metaMDS(tree_am, k = 3, trymax = 100)
save(tree_count_mds, tree_relab_mds, file = "../Results/mds_out.Rdata")

# load("../Results/mds_out.Rdata")

# read in species count matrix for each census
mammal_df <- read.csv("../Results/mammals_matrix.csv", header=T, row.names=1)
mammal_cm <- count_matrix(mammal_df)
mammal_am <- rel_abnd(mammal_df)

# NMDS on relative abundance matrix
# ***NOT SURE THIS IS RIGHT AS NOW THE DIFFERENT CENSUS' ARE NOT COMPARABLE***
mammal_count_mds <- metaMDS(mammal_cm, k = 3, trymax = 100)
mammal_relab_mds <- metaMDS(mammal_am, k = 3, trymax = 100)
save(mammal_count_mds, mammal_relab_mds, file = "../Results/mammal_mds_out.Rdata")

# read in species count matrix for each census
beetle_df <- read.csv("../Results/beetles_matrix.csv", header=T, row.names=1)
beetle_cm <- count_matrix(beetle_df)
beetle_am <- rel_abnd(beetle_df)

# NMDS on relative abundance matrix
# ***NOT SURE THIS IS RIGHT AS NOW THE DIFFERENT CENSUS' ARE NOT COMPARABLE***
beetle_count_mds <- metaMDS(beetle_cm, k = 3, trymax = 100)
beetle_relab_mds <- metaMDS(beetle_am, k = 3, trymax = 100)
save(beetle_count_mds, beetle_relab_mds, file = "../Results/mammal_mds_out.Rdata")
