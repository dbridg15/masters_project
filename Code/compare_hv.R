#!usr/bin/env Rscript

# script: compare_hv.R 
# Desc:   
# Author: David Bridgwood (dmb2417@ic.ac.uk)

# require
source("00_hv_functions.R")

###############################################################################
#
###############################################################################

load("../Results/tree_mds_out.Rdata")
load("../Results/beetle_mds_out.Rdata")
load("../Results/mammal_mds_out.Rdata")


# overall dataframe from species ordination
tree_df   <- as.data.frame(tree_relab_mds$points)
mammal_df <- as.data.frame(mammal_relab_mds$points)
beetle_df <- as.data.frame(beetle_relab_mds$points)


# function...
test <- function(df){

  df$plot    <- unlist(strsplit(row.names(df), "_"))[ c(T,F,F)]
  df$subplot <- unlist(strsplit(row.names(df), "_"))[ c(F,T,F)]
  df$census  <- unlist(strsplit(row.names(df), "_"))[ c(F,F,T)]


  # compare census, same plot
  for (i in unique(df$plot)){
    cat(paste0("\n\n==============================================================================="))
    cat(paste("\nPlot:", i, "\n"))
    assign(paste0(tolower(i), "_df"), subset(df, plot == i))
    assign(paste0(tolower(i), "_cc"), 
           compare_hypervolumes(df = subset(df, plot == i), compare = "census",
                                type = "svm", plot = FALSE))
  }


  # compare plot, same census
  for (i in unique(df$census)){
    cat(paste0("\n\n==============================================================================="))
    cat(paste("\nCensus:", i, "\n"))
    assign(paste0(tolower(i), "_df"), subset(df, census == i))
    assign(paste0(tolower(i), "_cc"), 
           compare_hypervolumes(df = subset(df, census == i), compare = "plot",
                                type = "svm", plot = FALSE))
  }

  return(df)
}


tree_df   <- test(tree_df)
mammal_df <- test(mammal_df)
beetle_df <- test(beetle_df)
