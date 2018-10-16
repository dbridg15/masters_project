#!usr/bin/env Rscript

# script: 00_functions.R 
# Desc:   contains all R functions for project
# Author: David Bridgwood (dmb2417@ic.ac.uk)

# require
cat("\n loading required packages\n\n")
suppressPackageStartupMessages(require(vegan))
suppressPackageStartupMessages(require(hypervolume))
suppressPackageStartupMessages(require(plyr))        # bit dodgy that i need both...
suppressPackageStartupMessages(require(dplyr))       # bit dodgy that i need both...
suppressPackageStartupMessages(require(codyn))
suppressPackageStartupMessages(require(reshape2))
suppressPackageStartupMessages(require(RColorBrewer))
suppressPackageStartupMessages(require(ggplot2))

# TODO!
  ## neaten up compare_census()


###############################################################################
# classes
###############################################################################

################################### pca.out ###################################

setClass("pca.out", slots = c(tot.chi = "numeric",       # total inertia
                              exp.var = "numeric",       # total explained varience of first 10 PCs
                              axis    = "data.frame",    # the points in pca space
                              CA      = "list",          # much of the output from the rda func
                              Ybar    = "matrix",
                              inertia = "character"))    # what is the inertia (varience/correlation)


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
  
  # to plot or not
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

  # scle only the specified axis
  out <- df[, axis]
  out <- as.data.frame(scale(out))

  # add some useful columns
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
#' @param what either seq - sequenital census compared (1-2, 2-3, 3-4) or all
#' @export
#' @examples
#' compare_census(df, hv_list)

compare_census <- function(df, hv_list, what = "seq"){

  # set up df to store results
  
  cen     <- sort(unique(df$census))  # all censuses in order
  plts    <- unique(df$plot)
  compcen <- combn(cen, 2)            # every possible combination of censuses

  # which censuses to compare
  if (what == "all"){ 
    tmp  <- paste0(compcen[1, ], "-", compcen[2, ])
  } else if (what == "seq"){
    tmp  <- paste0(cen[1:length(cen)-1], "-", cen[2:length(cen)])
  }
  
  # stick the plots in front
  comp <- sort(as.vector(outer(plts, tmp, paste, sep="_")))
  
  # set up dataframe for results
  compare <- data.frame(matrix(NA,
                               nrow = length(comp), 
                               ncol = 8))
    
  rownames(compare)   <- comp
  colnames(compare)   <- c("plot",
                           "census_step",
                           "centroid_change",
                           "overlap",
                           "unique_1",
                           "unique_2",
                           "abs_vol_change",
                           "per_vol_change")
  compare$plot        <- unlist(strsplit(unlist(comp), "_"))[ c(T, F)]
  compare$census_step <- unlist(strsplit(unlist(comp), "_"))[ c(F, T)]

  # do some cleanup
  rm(tmp, comp, cen, plts)

  # do the comparisons

  cat("\n")

  for (i in rownames(compare)){
    
    # let the user know whats going on
    cat("\rComparing Hypervolume",
        sprintf("%02d", which(rownames(compare) == i)), " of ",         # where we're at
        sprintf("%02d", nrow(compare)), ": ",                           # number of comparisons
        sprintf(paste0("%-0", max(nchar(rownames(compare))), "s"), i))  # plot_c1-c2

    # hypervolumes taken from hv_list based on row currently in
    hv1 <- hv_list[[paste0(compare[i, "plot"], "_", unlist(strsplit(compare[i, "census_step"], "-"))[c(T, F)])]]
    hv2 <- hv_list[[paste0(compare[i, "plot"], "_", unlist(strsplit(compare[i, "census_step"], "-"))[c(F, T)])]]

    # if both hvs actually have data in them
    if( class(hv1) == "Hypervolume" && class(hv2) == "Hypervolume"){

      sink("temp.txt", append = TRUE)  # keep output useful (dont print all the crap)

      hvset = hypervolume_set(hv1, hv2, check.memory = F, verbose = F)

      compare[i, "centroid_change"] <- hypervolume_distance(hv1, hv2)                # distance between centroids
      compare[i, "overlap"]         <- hypervolume_overlap_statistics(hvset)[1]      # intersection/union
      compare[i, "unique_1"]        <- hypervolume_overlap_statistics(hvset)[3]      # unique fraq1
      compare[i, "unique_2"]        <- hypervolume_overlap_statistics(hvset)[4]      # unique fraq2
      compare[i, "abs_vol_change"]  <- get_volume(hv2) - get_volume(hv1)             # absolute change in volume
      compare[i, "per_vol_change"]  <- compare[i, "abs_vol_change"]/get_volume(hv1)  # % change in volume

      sink()  # finish the sink
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
#' @param what - either seq - only sequenital census compared (1-2, 2-3, 3-4) or all
#' @param census_time - dataframe with information on time differences between censuses
#' @param - 'gaussian' or 'svm' method for building hypervolumes
#' @export
#' @examples
#' hvs_rslts(df, axis = c("PC1", "PC2", "PC3"))

hvs_rslts <- function(df, axis, what = "seq", census_time, method = 'gaussian'){

  df <- standardise_time(df, axis, census_time)  # standardise to t = 1-year
  df <- scale_axis(df, axis)                     # scale_axis

  # all the possible comparisons
  names <- sort(as.vector(outer(unique(df$plot), unique(df$census), paste, sep="_")))

  cols <- c("plot",
            "census",
            paste0("centroid_", axis),
            paste0(axis, "_l"),
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
    
    # let the user know whats going on
    cat("\rBuilding Hypervolume ",
        sprintf("%02d", which(names == i)), " of ",         # where we're at 
        sprintf("%02d", length(names)), ": ",               # total number
        sprintf(paste0("%-0", max(nchar(names)), "s"), i))  # plot_c

    p <- unlist(strsplit(i, "_"))[[1]]  # plot
    c <- unlist(strsplit(i, "_"))[[2]]  # census

    # subset of the pca space with require plot/census and PCs
    tmp <- subset(df,
                  plot == p & census == c,
                  select = colnames(df)[!(colnames(df) %in% c("plot", "subplot", "census"))])

    if (nrow(unique(round(tmp, 12))) < 2){ # if theres not enough data
      hv <- NA                             # then the hv is empty
    } else{                                # otherwise
      suppressWarnings(  # some sites produce warnings as they dont have quite enough data to construct hvs properly (limitation!) 
        hv <- hypervolume(tmp, method = method, name = i, verbose = FALSE)
      )
    }
    
    hvlist[[i]] <- hv  # add the hv to the hvlist
      
    rslts[i, "plot"]   <- unlist(strsplit(i, "_"))[1]
    rslts[i, "census"] <- unlist(strsplit(i, "_"))[2]

    if (class(hv) == "Hypervolume"){  # if the hv has data in it
      # fill results with some hv descriptors/stats
      rslts[i, "volume"] <- hv@Volume

      a <- as.data.frame(get_centroid(hv))

      for (z in rownames(a)){
        rslts[i, paste0("centroid_", z)] <- a[z, ]
        rslts[i, paste0(z, "_l")]        <- min(hv@RandomPoints[,z])
        rslts[i, paste0(z, "_h")]        <- max(hv@RandomPoints[,z])
      }
    }     
  }
  
  # put results through compare census
  compare <- compare_census(rslts, hvlist, what = what)

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
#' plot_hvs(df, plt)

plot_hvs <- function(hvs.rslts, plt){
    
  # pull out data for tje specified plot
    match_plt <- which(unlist(strsplit(names(hvs.rslts@hvlist), "_"))[c(T, F)] == plt)

    # get rid of empty hvs and save in class HypervolumeList
    hvlist <- hvs.rslts@hvlist[match_plt]
    hvlist <- hvlist[which(!is.na(hvlist))]
    hvlist <- new("HypervolumeList", HVList = hvlist)

    # plot
    plot(hvlist,
        contour.type      = "kde",
        cex.random        = 0.3,
        cex.centroid      = 2.5,
        cex.data          = 1,
        cex.axis          = 1,
        point.dark.factor = 0.2,
        colors            = brewer.pal(max(c(length(match_plt), 3)), "Set2")
        )
}


########################### standardise_time ##################################

#' returns points adjusted to position at standardise_time t=1year 
#' 
#' @param df a dataframe which is the axis of hypervolume as columns and plots/census as rows 
#' @param axix a vector of axis that hypervolumes will be constructed from
#' @param census_time data with time differences beteen censuses
#' @export
#' @examples
#' standardise_time(df, axis, census_time)

standardise_time = function(df, axis, census_time){
  
  # select required axis
  df = df[, axis]

  # get list of plots
  plts = unique(unlist(strsplit(rownames(df), "_"))[c(T, F, F)])

  # we'll save stuff to out so delete if it exists
  if (exists('out')){ rm(out) }

  for (plt in plts){
  
    tmp1 <- df[which(unlist(strsplit(rownames(df), "_"))[c(T, F, F)] == plt), ]  # get the specified plt
    splt <- unique(unlist(strsplit(rownames(tmp1), "_"))[c(F, T, F)])            # subplots
    cens <- sort(unique(unlist(strsplit(rownames(tmp1), "_"))[c(F, F, T)]))      # censuses

    # blank df with subplot, axis and census as axes
    raw <- array(dim= c(length(splt), ncol(df), length(cens)),
                 dimnames = list(splt, axis, cens))

    adj <- raw

    # put raw data in raw
    for (sp in splt){ for (cen in cens){
      raw[sp, , cen] <- unlist(tmp1[paste(plt, sp, cen, sep = "_"), ])
    }}

    # adj starts off as raw
    adj[,,cens[1]] <- raw[,,cens[1]]
    
    # if theres more than one census then we'll have to do some adjusting
    if (length(cens) > 1){ 
      for (c in 2:length(cens)){
        
        # get census time for specific plot and census
        mask <- census_time$plot == plt & census_time$census == cens[c]

      if (sum(mask, na.rm = TRUE) == 0) { # was getting some weird errors
        adj[ , , cens[c]] <- NA
      } else {
        diff_yrs <- census_time[mask, "diff_yrs"]
        # where would the raw point be if diff_yrs = 1
        adj[,,cens[c]] <- raw[,,cens[c-1]] + ((raw[,,cens[c]] - raw[,,cens[c-1]])*(1/diff_yrs)) 
      }}}

    adj <- adply(adj, c(1, 3))  # put back in a useable format

    colnames(adj)[1:2] <- c('subplot', 'census')
    adj$plot           <- plt
    rownames(adj)      <- paste(adj$plot, adj$subplot, adj$census, sep = "_")

    adj <- adj[order(rownames(adj)), ]
    adj <- na.omit(adj)

    # create or add onto out
    if (exists('out')){
      out = rbind(out, adj)
    } else {
      out = adj
    }
  }
  return(out)
}


############################### add_cols #####################################


#' adds columns for plot, subplot and census  
#' 
#' @param df with rownames in form plot_subplot_census 
#' @export
#' @examples
#' standardise_time(df)

add_cols = function(df){
    df$plot    = unlist(strsplit(rownames(df), "_"))[ c(T,F,F)]
    df$subplot = unlist(strsplit(rownames(df), "_"))[ c(F,T,F)]
    df$census  = unlist(strsplit(rownames(df), "_"))[ c(F,F,T)]
    
    return(df)
    }


###########################  spatial_stability ################################

#' calculate measure of spatial stability (using Lehman and Tilman equation)  
#' 
#' @param df with plot, subplot, census, species, count as columns
#' @export
#' @examples
#' spatial_stability(df)

spatial_stability = function(df){
    # will calculate seperatly for each plot
    plts <- unique(df$plot)

    for(plt in plts){
        a         <- subset(df, plot == plt)
        a$subplot <- as.numeric(as.factor(a$subplot))  # get the subplots

        if(exists('b')){ b <- rbind(b, a) } else{ b <- a }
    }

    df        <- b
    df$census <- paste0(df$plot, "_", df$census)

    stability <- community_stability(df, 
                                     time.var      = "subplot", 
                                     abundance.var = "value", 
                                     replicate.var = "census")
    return(stability)
    }


####################### temporal_stability ####################################

#' calculate measure of temporal stability (using Lehman and Tilman equation)  
#' 
#' @param df with plot, subplot, census, species, count as columns
#' @export
#' @examples
#' temporal_stability(df)

temporal_stability = function(df){
    # will calculate seperatly for each plot
    plts = unique(df$plot)

    for(plt in plts){
        a        <- subset(df, plot == plt)
        a$census <- as.numeric(as.factor(a$census))

        if(exists('b')){ b = rbind(b, a) } else{ b = a }
    }

    df <- b

    stability <- community_stability(df, 
                                     time.var = "census", 
                                     abundance.var = "value", 
                                     replicate.var = "plot")
    return(stability)
    }