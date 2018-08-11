#!usr/bin/env Rscript

# script: 00_functions.R 
# Desc:   contains all R functions for project
# Author: David Bridgwood (dmb2417@ic.ac.uk)

# require
require(ggplot2)
source("00_functions.R")


###############################################################################
#
###############################################################################


# read in data
trees_df = read.csv("../Results/trees_matrix.csv", row.names=1)
# trees_df   = read.csv("../Results/trees_genus_matrix.csv", row.names=1)
mamls_df = read.csv("../Results/mammals_matrix.csv", row.names=1)
btles_df = read.csv("../Results/beetles_matrix.csv", row.names=1)

trees_cen  = read.csv("../Results/trees_census_dates.csv")
btles_cen  = read.csv("../Results/beetles_census_dates.csv")
mamls_cen  = read.csv("../Results/mammals_census_dates.csv")

# do the pca on communities to reduce number of axis
pca.rslt_trees = do_pca(trees_df, scale = F, plot = F)
pca.rslt_mamls = do_pca(mamls_df, scale = F, plot = F)
pca.rslt_btles = do_pca(btles_df, scale = F, plot = F)

# print output to the terminal
cat("Explained Varience Trees:")
pca.rslt_trees@exp.var
cat("Explained Varience Mammals:")
pca.rslt_mamls@exp.var
cat("Explained Varience Beetles:")
pca.rslt_btles@exp.var


# build and compare hypervolumes
hvs_rslts_trees = hvs_rslts(pca.rslt_trees@axis, axis = c("PC1", "PC2", "PC3"), "seq", trees_cen)
hvs_rslts_mamls = hvs_rslts(pca.rslt_mamls@axis, axis = c("PC1", "PC2", "PC3"), "seq", mamls_cen)
hvs_rslts_btles = hvs_rslts(pca.rslt_btles@axis, axis = c("PC1", "PC2", "PC3"), "seq", btles_cen)

cat("\n\n")
cat("Trees: ",   sum(is.na(hvs.rslts_trees@rslts$centroid_PC1))/nrow(hvs.rslts_trees@rslts), "\n")
cat("Mammals: ", sum(is.na(hvs.rslts_mammals@rslts$centroid_PC1))/nrow(hvs.rslts_mammals@rslts), "\n")
cat("Beetles: ", sum(is.na(hvs.rslts_beetles@rslts$centroid_PC1))/nrow(hvs.rslts_beetles@rslts))

# saving output
save(hvs_rslts_trees, hvs_rslts_mamls, hvs_rslts_btles,
     file = "../Results/compare_hv.Rout")


# boxplot!
b = data.frame(group = "beetles", overlap = hvs_rslts_btles@compare$overlap)
t = data.frame(group = "trees",   overlap = hvs_rslts_trees@compare$overlap)
m = data.frame(group = "mammals", overlap = hvs_rslts_mamls@compare$overlap)

whisker = rbind(b, t, m)
whisker = whisker[complete.cases(whisker), ]

plt = ggplot(data = whisker, aes(x = group, y = overlap, color = group))
plt = plt + geom_boxplot()
plt = plt + geom_point(alpha = 0.5)
plt = plt + theme_classic()
print(plt)


# other plots
# plot_hvs(hvs_rslts_trees)
