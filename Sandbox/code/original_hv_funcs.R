#!usr/bin/env Rscript

# script: test_PCA.R 
# Desc:   
# Author: David Bridgwood (dmb2417@ic.ac.uk)

# require
require(vegan)
require(hypervolume)

# TODO
#   *Is hypervolume_svm the correct method?


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

# hypervolume comparisons
setClass("hv_comp", slots = c(name                 = "character",
                              hvlist               = "HypervolumeList",
                              distance_matrix      = "matrix",
                              jaccard_matrix       = "matrix",
                              intersection_matrix  = "matrix",
                              union_matrix         = "matrix",
                              unique_componant_row = "matrix"))                               

#' Function to Compare Hypervolumes
#' 
#' returns HypervolumeList and adjacency matrices of comparison
#' @param df A dataframe with columns for each axis for hypervolumes and plot, subplot & census 
#' @param compare Either plot or census
#' @param type How to calculate Hypervolumes. Either svm (default) or gaussian
#' @param plot If true Hypervolumes are plotted. Default FALSE
#' @export
#' @examples
#' compare_hypervolumes(tower_df, "census", "gaussian", TRUE)

compare_hypervolumes <- function(df, compare, type = "svm", plot = FALSE ){

  # compare list
  if (compare == "census"){
    compare_list <- unique(df$census)
    nam_str      <- paste("Plot:", df$plot[1], "comparing census")
  } else if (compare == "plot"){
    compare_list <- unique(df$plot)
    nam_str      <- paste("Census:", df$census[1], "comparing plots")
  } else{
    print("compare must be either 'census' or 'plot'")
    return()
  }
  
  # empty list
  hvlist <- list()

  cat("\n")

  # for each census make hv and append to list
  for (i in compare_list){

    cat("\rBuilding Hypervolume ", which(compare_list == i), " of ", length(compare_list))

    if (compare == "census"){
      tmp_df <- subset(df, census == i, select = colnames(df)[!(colnames(df) %in% c("plot", "subplot", "census"))])
    } else if (compare == "plot"){
      tmp_df <- subset(df, plot   == i, select = colnames(df)[!(colnames(df) %in% c("plot", "subplot", "census"))])
    }
    
    if (type == "svm"){
      hv <- hypervolume_svm(tmp_df, name = i, verbose = F)
    } else if (type == "gaussian"){
      hv <- hypervolume_gaussian(tmp_df, name = i, verbose = F)
    } else {
      print("type must be 'svm' or 'gaussian'")
      return()
    }

    hvlist[[i]] <- hv

  }

  # as class HypervolumeList
  hvlist <- new("HypervolumeList", HVList = hvlist)

  # set up a blank template matrix
  blank_matrix <- matrix(nrow = length(compare_list),
                         ncol = length(compare_list))

  rownames(blank_matrix) <- compare_list
  colnames(blank_matrix) <- compare_list

  distance_matrix      <- blank_matrix
  jaccard_matrix       <- blank_matrix
  intersection_matrix  <- blank_matrix
  union_matrix         <- blank_matrix
  unique_componant_row <- blank_matrix

  # possible pairs...
  pairs <- combn(compare_list, 2)

  cat("\n\n")

  # compare all pairs
  for (i in 1:ncol(pairs)){

    cat("\rComparing Hypervolume pairs", i, " of ", ncol(pairs))

    row <- pairs[1, i]
    col <- pairs[2, i]

    sink("temp.txt", append = TRUE)
    set <- hypervolume_set(hvlist[[row]], hvlist[[col]], check.memory = F, verbose = F)

    distance_matrix[row, col]      <- hypervolume_distance(hvlist[[row]], hvlist[[col]])
    jaccard_matrix[row, col]       <- hypervolume_overlap_statistics(set)[1]
    intersection_matrix[row, col]  <- get_volume(set)[3] 
    union_matrix[row, col]         <- get_volume(set)[4] 
    unique_componant_row[row, col] <- get_volume(set)[5]
    unique_componant_row[col, row] <- get_volume(set)[6]
    sink()
  }

  file.remove("temp.txt")
  cat("\n\n")

  comparison <- new("hv_comp",
                    name                 = nam_str,
                    hvlist               = hvlist,
                    distance_matrix      = distance_matrix,
                    jaccard_matrix       = jaccard_matrix,
                    intersection_matrix  = intersection_matrix,
                    union_matrix         = union_matrix,
                    unique_componant_row = unique_componant_row)

  if (plot == TRUE){
    plot(hvlist)
  }

  return(comparison)

} 
