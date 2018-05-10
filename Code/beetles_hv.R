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

# read in species count matrix for each census
beetle_df <- read.csv("../Results/beetles_matrix.csv", header=T, row.names=1)
beetle_cm <- count_matrix(beetle_df)

# NMDS on relative abundance matrix
# ***NOT SURE THIS IS RIGHT AS NOW THE DIFFERENT CENSUS' ARE NOT COMPARABLE***




##** THIS TAKES FOREVER!! SORT IT SO ITS BETTER!! **##
#count_mds <- metaMDS(beetle_cm, k = 3, trymax = 30)
#save(count_mds, file = "../Results/beetles_mds.Rdata")

load("../Results/beetles_mds.Rdata")

# function to compare two hypervolumes from different census' for same plot
compare_census <- function(mds, c1_str, c2_str, plot_str){

  plot_index <- which(unlist(strsplit(row.names(mds$points), "_"))[ c(F,T)] == plot_str) 
  c1_index   <- which(unlist(strsplit(row.names(mds$points), "_"))[ c(T,F)] == c1_str)
  c2_index   <- which(unlist(strsplit(row.names(mds$points), "_"))[ c(T,F)] == c2_str)

  df1 <- mds$points[plot_index[which(plot_index %in% c1_index)], ]
  df2 <- mds$points[plot_index[which(plot_index %in% c2_index)], ]

  hv1 <- hypervolume_svm(df1, name = paste(plot_str, c1_str))
  hv2 <- hypervolume_svm(df2, name = paste(plot_str, c2_str))

  hypervolume_distance(hv1, hv2)

  hvset <- hypervolume_set(hv1, hv2, check.memory=F)

  hypervolume_overlap_statistics(hvset)
  get_volume(hvset)

  plot(hvset, show.3d=T, cex.centroid=15, cex.random=3, cex.data=5)

  return(hvset)
}

compare_census(count_mds, "P2", "P3", "OP")


# function to compare two hypervolumes from different plots for same census
compare_plot <- function(mds, plt1_str, plt2_str, cen_str){

  plt1_index <- which(unlist(strsplit(row.names(mds$points), "_"))[ c(T,F,F)] == plt1_str) 
  plt2_index <- which(unlist(strsplit(row.names(mds$points), "_"))[ c(T,F,F)] == plt2_str) 
  cen_index  <- which(unlist(strsplit(row.names(mds$points), "_"))[ c(F,F,T)] == cen_str)

  df1 <- mds$points[cen_index[which(cen_index %in% plt1_index)], ]
  df2 <- mds$points[cen_index[which(cen_index %in% plt2_index)], ]

  hv1 <- hypervolume_svm(df1, name = paste(plt1_str, cen_str))
  hv2 <- hypervolume_svm(df2, name = paste(plt2_str, cen_str))

  hypervolume_distance(hv1, hv2)

  hvset <- hypervolume_set(hv1, hv2, check.memory=F)

  hypervolume_overlap_statistics(hvset)
  get_volume(hvset)

  plot(hvset, show.3d=T, cex.centroid=15, cex.random=3, cex.data=5)

  return(hvset)
}

compare_plot(count_mds, "BNorth", "Tower", "c4")


