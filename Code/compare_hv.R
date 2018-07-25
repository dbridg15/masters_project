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
trees_df   = read.csv("../Results/trees_genus_matrix.csv", row.names=1)
mammals_df = read.csv("../Results/mammals_matrix.csv", row.names=1)
beetles_df = read.csv("../Results/beetles_matrix.csv", row.names=1)

# do pca
pca.rslt_trees   = do_pca(trees_df, scale = F, plot = F)
pca.rslt_mammals = do_pca(mammals_df, scale = F, plot = F)
pca.rslt_beetles = do_pca(beetles_df, scale = F, plot = F)

cat("\n\nExplained Varience Trees: ", pca.rslt_trees@exp.var, "\n")
cat("\n\nExplained Varience Mammals: ", pca.rslt_mammals@exp.var, "\n")
cat("\n\nExplained Varience Beetles: ", pca.rslt_beetles@exp.var, "\n")


# make and compare hypervolumes
hvs_rslts_trees   = hvs_rslts(pca.rslt_trees@axis, axis = c("PC1", "PC2", "PC3"))
hvs_rslts_mammals = hvs_rslts(pca.rslt_mammals@axis, axis = c("PC1", "PC2", "PC3"))
hvs_rslts_beetles = hvs_rslts(pca.rslt_beetles@axis, axis = c("PC1", "PC2", "PC3"))

cat("\n\nTrees % NA: ",   sum(is.na(hvs_rslts_trees@rslts$centroid_PC1))/nrow(hvs_rslts_trees@rslts), "\n")
cat("\n\nMammals % NA: ", sum(is.na(hvs_rslts_mammals@rslts$centroid_PC1))/nrow(hvs_rslts_mammals@rslts), "\n")
cat("\n\nBeetles % NA: ", sum(is.na(hvs_rslts_beetles@rslts$centroid_PC1))/nrow(hvs_rslts_beetles@rslts), "\n")


# plot hypervolumes

pdf("../Results/plots/trees_community.pdf")
  plot_hvs(hvs_rslts_trees)
dev.off()

pdf("../Results/plots/beetles_community.pdf")
  plot_hvs(hvs_rslts_beetles)
dev.off()

pdf("../Results/plots/mammals_community.pdf")
  plot_hvs(hvs_rslts_mammals)
dev.off()


# saving output

save(hvs_rslts_trees, hvs_rslts_mammals, hvs_rslts_beetles, file = "../Results/compare_hv.Rout")




