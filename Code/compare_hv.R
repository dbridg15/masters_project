#!usr/bin/env Rscript

# script: test_PCA.R 
# Desc:   
# Author: David Bridgwood (dmb2417@ic.ac.uk)

# require
source("hv_functions.R")

###############################################################################
#
###############################################################################

# overall dataframe from species ordination
all_df         <- as.data.frame(count_mds$points)
all_df$plot    <- unlist(strsplit(row.names(all_df), "_"))[ c(T,F,F)]
all_df$subplot <- unlist(strsplit(row.names(all_df), "_"))[ c(F,T,F)]
all_df$census  <- unlist(strsplit(row.names(all_df), "_"))[ c(F,F,T)]

# compare census, same plot
for (i in unique(all_df$plot)){
  cat(paste("Plot:", i, "\n"))
  assign(paste0(tolower(i), "_df"), subset(all_df, plot == i))
  assign(paste0(tolower(i), "_cc"), 
         compare_hypervolumes(df = subset(all_df, plot == i), compare = "census", type = "svm", plot = TRUE))
}


# compare plot, same census
for (i in unique(all_df$census)){
  cat(paste("Census:", i, "\n"))
  assign(paste0(tolower(i), "_df"), subset(all_df, census == i))
  assign(paste0(tolower(i), "_cc"), 
         compare_hypervolumes(df = subset(all_df, census == i), compare = "plot", type = "svm", plot = TRUE))
}
