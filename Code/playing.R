source("00_functions.R")

# read in data
trees_df   = read.csv("../Results/trees_genus_matrix.csv", row.names=1)
mammals_df = read.csv("../Results/mammals_matrix.csv", row.names=1)
beetles_df = read.csv("../Results/beetles_matrix.csv", row.names=1)

# do pcas
pca.rslt_trees   = do_pca(trees_df, scale = F, plot = F)
cat("Explained Varience Trees:")
pca.rslt_trees@exp.var

pca.rslt_mammals = do_pca(mammals_df, scale = F, plot = F)
cat("Explained Varience Mammals:")
pca.rslt_mammals@exp.var

pca.rslt_beetles = do_pca(beetles_df, scale = F, plot = F)
cat("Explained Varience Beetles:")
pca.rslt_beetles@exp.var


# calculate and compare Hypervolumes
hvs.rslts_trees   = hvs_rslts(pca.rslt_trees@axis)
hvs.rslts_mammals = hvs_rslts(pca.rslt_mammals@axis)
hvs.rslts_beetles = hvs_rslts(pca.rslt_beetles@axis)
















attributes <- read.csv("../Results/trees_sorted.csv")
a = as.data.frame(attributes %>% group_by(plot_c) %>% summarise(stem_C = sum(stem_C)))

rslts = merge(rslts, a, by = "plot_c", all.x = T)
