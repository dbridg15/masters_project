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
mammal_df <- read.csv("../Results/mammals_matrix.csv", header=T, row.names=1)
mammal_cm <- count_matrix(mammal_df)

# NMDS on relative abundance matrix
# ***NOT SURE THIS IS RIGHT AS NOW THE DIFFERENT CENSUS' ARE NOT COMPARABLE***
count_mds <- metaMDS(mammal_cm, k = 3, trymax = 100)
save(count_mds, file = "../Results/mammal_mds_out.Rdata")

#load("../Results/mammal_mds_out.Rdata")

# function to compare two hypervolumes from different census' for same plot
compare_year <- function(mds, y1_str, y2_str, plot_str){

  plot_index <- which(unlist(strsplit(row.names(mds$points), "-"))[ c(T,F,F,F)] == plot_str) 
  y1_index   <- which(unlist(strsplit(row.names(mds$points), "-"))[ c(F,F,T,F)] == y1_str)
  y2_index   <- which(unlist(strsplit(row.names(mds$points), "-"))[ c(F,F,T,F)] == y2_str)

  df1 <- mds$points[plot_index[which(plot_index %in% y1_index)], ]
  df2 <- mds$points[plot_index[which(plot_index %in% y2_index)], ]

  hv1 <- hypervolume_svm(df1, name = paste(plot_str, y1_str))
  hv2 <- hypervolume_svm(df2, name = paste(plot_str, y2_str))

  hypervolume_distance(hv1, hv2)

  hvset <- hypervolume_set(hv1, hv2, check.memory=F)

  hypervolume_overlap_statistics(hvset)
  get_volume(hvset)

  plot(hvset, show.3d=T, cex.centroid=15, cex.random=3, cex.data=5)

  return(hvset)
}

compare_year(count_mds, "2012", "2014", "E100")


# function to compare two hypervolumes from different plots for same census
compare_plot <- function(mds, plt1_str, plt2_str, year_str){

  plt1_index <- which(unlist(strsplit(row.names(mds$points), "-"))[ c(T,F,F,F)] == plt1_str) 
  plt2_index <- which(unlist(strsplit(row.names(mds$points), "-"))[ c(T,F,F,F)] == plt2_str) 
  year_index <- which(unlist(strsplit(row.names(mds$points), "-"))[ c(F,F,T,F)] == year_str)

  df1 <- mds$points[year_index[which(year_index %in% plt1_index)], ]
  df2 <- mds$points[year_index[which(year_index %in% plt2_index)], ]

  hv1 <- hypervolume_svm(df1, name = paste(plt1_str, year_str))
  hv2 <- hypervolume_svm(df2, name = paste(plt2_str, year_str))

  hypervolume_distance(hv1, hv2)

  hvset <- hypervolume_set(hv1, hv2, check.memory=F)

  hypervolume_overlap_statistics(hvset)
  get_volume(hvset)

  plot(hvset, show.3d=T, cex.centroid=15, cex.random=3, cex.data=5)

  return(hvset)
}

compare_plot(count_mds, "E100", "E10", "2014")

#hypervolume_save_animated_gif(image.size = 1000, axis = c(0, 0, 1), rpm = 4,
#                              duration = 15, fps = 20, file.name = "movie",
#
