#!usr/bin/env Rscript

# script: 00_functions.R 
# Desc:   contains all R functions for project
# Author: David Bridgwood (dmb2417@ic.ac.uk)

# require
cat("\n loading required packages\n\n")
require(vegan)
require(hypervolume)
require(dplyr)


# TODO!
# - would be nice if the hvs_rslts function could take any datframe not just
# the pca output.

###############################################################################
# classes
###############################################################################

################################### pca.out ###################################

setClass("pca.out", slots = c(tot.chi = "numeric",     # total inertia
                              exp.var = "numeric",     # total explained varience of first 10 PCs
                              axis    = "data.frame",  # the points in pca space
                              CA      = "list",        # much of the output from the rda func
                              Ybar    = "matrix",
                              inertia = "character"))  # what is the inertia (varience/correlation)


################################## hv.rslts ###################################

setClass("hv.rslts", slots = c(hvlist  = "list",         # list of hypervolumes
                               rslts   = "data.frame",   # summary hv stats
                               compare = "data.frame"))  # summary comparison stats


###############################################################################
# functions
###############################################################################


################################### do_pca ####################################

#' Function to run pca and save output ready to construct hypervolumes
#' 
#' returns HypervolumeList and adjacency matrices of comparison
#' @param df A dataframe with columns for each species and rows for each subplot/census 
#' @param scale TRUE/FALSE scale species counts. Default FALSE
#' @param plot  TRUE/FALSE pca biplot is produced. Default FALSE
#' @export
#' @examples
#' do_pca(trees_df, scale = TRUE, plot = FALSE)

do_pca <- function(df, scale = FALSE, plot = FALSE){

  # if i did want to do relative abundance?
  # df = apply(df, 1, function(x) x/sum(x))

  # do the pca
  df.pca = rda(df, scale = scale)
  
  # store the output in pca.out class
  out = new("pca.out", tot.chi = df.pca$tot.chi,
                       exp.var = head(df.pca$CA$eig/df.pca$tot.chi, 10),
                       axis    = as.data.frame(df.pca$CA$u),
                       CA      = df.pca$CA,
                       Ybar    = df.pca$Ybar,
                       inertia = df.pca$inertia)
  
  # add plot/subplot/census to axis points
  out@axis$plot    = unlist(strsplit(rownames(out@axis), "_"))[ c(T,F,F)]
  out@axis$subplot = unlist(strsplit(rownames(out@axis), "_"))[ c(F,T,F)]
  out@axis$census  = unlist(strsplit(rownames(out@axis), "_"))[ c(F,F,T)]
  
  if (plot == TRUE){
    biplot(df.pca, scaling = -1)
  }
  
  return(out)
}


################################# scale_axis ##################################

#' function makes datframe with scaled axis for creation of hv
#' 
#' returns a dataframe with comparisons of hypervolumes census to census
#' @param df a dataframe which is the output of pca
#' @param axis vector of axis names from which hv will be created 
#' @export
#' @examples
#' scale_axis(pca.rslt_trees@axis, axis = c("PC1", "PC2", "PC3"))

scale_axis <- function(df, axis){

  out <- df[, axis]
  out <- as.data.frame(scale(out))

  out$plot    <- df$plot
  out$subplot <- df$subplot
  out$census  <- df$census
  
  return(out)
}


################################ compare_census ###############################

#' function compares hypervolumes census to census
#' 
#' returns a dataframe with comparisons of hypervolumes census to census
#' @param df a dataframe which is the summary statistics of a hvlist   
#' @param hv_list a list containg all hypervolumes 
#' @export
#' @examples
#' compare_census(df, hv_list)

compare_census <- function(df, hv_list){

  # set up df to store results
  cen     <- sort(unique(df$census))  # all censuses in order (c1 - c2 - c3 -c4)
  plts    <- unique(df$plot)
  compcen <- combn(cen, 2)

  # df with row as each comparison and columns as stats
  compare <- data.frame(matrix(NA, nrow = length(plts)*ncol(compcen), ncol = 8))

  colnames(compare) <- c("plot", "census_step", "centroid_change", "overlap",
                         "unique_1", "unique_2", "abs_vol_change",
                         "per_vol_change")

  # there is DEFINATELY a mode efficient way of doing this...

  tmp <- list()
  for (i in 1:ncol(compcen)){
    tmp[[i]] <- paste0(compcen[1, i], "-", compcen[2, i])
  }
  comp <- list()
  for (p in plts){
    comp <- c(comp, paste0(p, "_", tmp))
  }

  rownames(compare)   <- comp

  compare$plot        <- unlist(strsplit(unlist(comp), "_"))[ c(T, F)]
  compare$census_step <- unlist(strsplit(unlist(comp), "_"))[ c(F, T)]

  # do some cleanup
  rm(tmp, comp, cen, plts)

  cat("\n")

  for (i in rownames(compare)){

    cat("\rComparing Hypervolume ", which(rownames(compare) == i), " of ",
        nrow(compare), ": ", i)

    # hypervolumes taken from hv_list based on row currently in
    hv1 = hv_list[[paste0(compare[i, "plot"], "_", unlist(strsplit(compare[i, "census_step"], "-"))[c(T, F)])]]
    hv2 = hv_list[[paste0(compare[i, "plot"], "_", unlist(strsplit(compare[i, "census_step"], "-"))[c(F, T)])]]

    # if both hvs actually have data in them
    if( class(hv1) == "Hypervolume" && class(hv2) == "Hypervolume"){

      sink("temp.txt", append = TRUE)  # keep output useful

      hvset = hypervolume_set(hv1, hv2, check.memory = F, verbose = F)

      compare[i, "centroid_change"] = hypervolume_distance(hv1, hv2)                # distance between centroids
      compare[i, "overlap"]         = hypervolume_overlap_statistics(hvset)[1]      # intersection/union
      compare[i, "unique_1"]        = hypervolume_overlap_statistics(hvset)[3]      # unique fraq1
      compare[i, "unique_2"]        = hypervolume_overlap_statistics(hvset)[4]      # unique fraq2
      compare[i, "abs_vol_change"]  = get_volume(hv2) - get_volume(hv1)             # absolute change in volume
      compare[i, "per_vol_change"]  = compare[i, "abs_vol_change"]/get_volume(hv1)  # % change in volume

      sink()
    }    
  }

  file.remove("temp.txt")

  return(compare)
}


################################# hvs_rslts ###################################

#' function produces and compares hypervolumes
#' 
#' returns a object of class hv.rslts with summary stats and comparisons of hypervolumes
#' @param df a dataframe which is the axis of hypervolume as columns and plots/census as rows 
#' @param axis - vector of axis from which to draw hypervolumes
#' @export
#' @examples
#' hvs_rslts(df, axis = c("PC1", "PC2", "PC3"))

hvs_rslts <- function(df, axis){

  df <- scale_axis(df, axis)

	# make list of hv names to work off 
  names <- c()
  for (p in unique(df$plot)){ for (c in unique(df$census)){
    names <- c(names, paste0(p, "_", c)) }}

  cols = c("plot", "census", paste0("centroid_", axis), paste0(axis, "_l"),
           paste0(axis, "_h"))

	# empty list to store hypervolumes as they're built
  hvlist <- list()

	# construct df to store summary stats for each hv
  rslts           <- data.frame(matrix(NA, nrow = length(names), ncol = length(cols)))
  colnames(rslts) <- cols
  rownames(rslts) <- names
  rslts$plot_c    <- names

  cat("\n")
    
  for (i in names){
    
    cat("\rBuilding Hypervolume ", which(names == i), " of ", length(names), ": ", i)

    p <- unlist(strsplit(i, "_"))[[1]]  # plot
    c <- unlist(strsplit(i, "_"))[[2]]  # census

		# subset of the pca space with require plot/census and PCs
    tmp <- subset(df, plot == p & census == c,
                  select = colnames(df)[!(colnames(df) %in% c("plot", "subplot", "census"))])

    if (nrow(tmp) < 2){
      hv <- NA
    } else{
      hv <- hypervolume_gaussian(tmp, name = i, verbose = FALSE)
    }
    
    hvlist[[i]] <- hv
      
    rslts[i, "plot"]   <- unlist(strsplit(i, "_"))[1]
    rslts[i, "census"] <- unlist(strsplit(i, "_"))[2]

    if (class(hv) == "Hypervolume"){

      rslts[i, "volume"]       <- hv@Volume

      a <- as.data.frame(get_centroid(hv))

      for (z in rownames(a)){
        rslts[i, paste0("centroid_", z)] <- a[z, ]
        rslts[i, paste0(z, "_l")]        <- min(hv@RandomPoints[,z])
        rslts[i, paste0(z, "_h")]        <- max(hv@RandomPoints[,z])
      }
    }     
  }
  
  # put results through compare census
  compare <- compare_census(rslts, hvlist)

  # save output to hv.rslts class
  out <- new("hv.rslts", hvlist = hvlist, rslts = rslts, compare = compare)

  cat("\n")

  return(out)
}


################################## plot_hvs ###################################

#' plots hypervolumes for a given plot
#' 
#' @param hv_rslts an object of class hvs.rslts
#' @export
#' @examples
#' plot_hvs(df)

plot_hvs <- function(hvs.rslts, plt){
    
    match_plt <- which(unlist(strsplit(names(hvs.rslts@hvlist), "_"))[c(T, F)] == plt)
    
    hvlist <- hvs.rslts@hvlist[match_plt]
    hvlist <- hvlist[which(!is.na(hvlist))]
    hvlist <- new("HypervolumeList", HVList = hvlist)
    
    plot(hvlist)
}
