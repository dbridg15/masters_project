source("00_functions.R")

trees_df        = read.csv("../Results/trees_matrix.csv", row.names=1)
trees_cen       = read.csv("../Results/trees_census_dates.csv")
pca.rslt_trees  = do_pca(trees_df, scale = F, plot = F)
hvs_rslts_trees = hvs_rslts(pca.rslt_trees@axis, axis = c("PC1", "PC2", "PC3"), "seq", trees_cen)


# plot functions

plot_hvs <- function(hvs.rslts){

  plts <- unique(hvs.rslts@compare$plot)

  for (plt in plts[1]){

    match_plt <- which(unlist(strsplit(names(hvs.rslts@hvlist), "_"))[c(T, F)] == plt)
    
    hvlist <- hvs.rslts@hvlist[match_plt]
    hvlist <- hvlist[which(!is.na(hvlist))]
    hvlist <- new("HypervolumeList", HVList = hvlist)
    
    plot.HypervolumeList(hvlist,
                         show.3d = TRUE,
                         show.frame = FALSE,
                         show.axes = TRUE,
                         show.legend = FALSE,
                         cex.random = 5,
                         cex.data = 7,
                         cex.centroid = 10,
                         show.random = TRUE,
                         contour.alphahull.alpha = 0.7,
                         point.alpha.min = 0.6,
                         point.alpha.max = 1
                         )
      
  }
}


plot_hvs(hvs_rslts_trees)
