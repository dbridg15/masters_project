require(vegan)
require(hypervolume)
require(dplyr)
source("00_hv_functions.R")

df = read.csv("../Results/trees_family_matrix.csv", row.names=1)
df = read.csv("../Results/trees_genus_matrix.csv", row.names=1)
df = read.csv("../Results/trees_matrix.csv", row.names=1)

df[is.na(df)] = 0

# dont think i want relative as it makes all plots seem the same in terms of overall...
# df = apply(df, 1, function(x) x/sum(x))

# do the pca from vegan package
df.pca = rda(df)

df.pca

# look at the varience it explains
# biplot(df.pca, scaling = -1)

df.pca$CA$eig[1]/df.pca$tot.chi
df.pca$CA$eig[2]/df.pca$tot.chi
df.pca$CA$eig[3]/df.pca$tot.chi
df.pca$CA$eig[4]/df.pca$tot.chi
df.pca$CA$eig[5]/df.pca$tot.chi
df.pca$CA$eig[6]/df.pca$tot.chi


# get the points to make hypervolumes from  
axis = df.pca$CA$u
axis = as.data.frame(axis)

axis$plot    = unlist(strsplit(rownames(axis), "_"))[ c(T,F,F)]
axis$subplot = unlist(strsplit(rownames(axis), "_"))[ c(F,T,F)]
axis$census  = unlist(strsplit(rownames(axis), "_"))[ c(F,F,T)]

# all the plot_census
names = c()
for (p in unique(axis$plot)){ for (c in unique(axis$census)){
    names = c(names, paste0(p, "_", c))
}}


# function to make hypervolumes for all..
make_hvs = function(df){
  
  hvlist = list()
  
  for (i in names){       

    p = unlist(strsplit(i, "_"))[[1]]
    c = unlist(strsplit(i, "_"))[[2]]

    tmp = subset(df, plot == p & census == c, select = c("PC1", "PC2", "PC3"))
        
    if (nrow(tmp) == 0){
        
        hv = NA 
        
    } else{
    
        hv = hypervolume_gaussian(tmp, name = i, verbose = FALSE)
    }
    
    hvlist[[i]] = hv

  }
  return(hvlist)
}

# run function
hvlist = make_hvs(axis)

# extract results
rslts           = data.frame(matrix(NA, nrow = length(names), ncol = 12))
colnames(rslts) = c("plot", "census", "centroid_PC1", "centroid_PC2",
                    "centroid_PC3", "volume", "PC1_l", "PC1_h", "PC2_l",
                    "PC2_h", "PC3_l", "PC4_h")
rownames(rslts) = names

for (i in names){
  hv = hvlist[[i]]
    
  rslts[i, "plot"]     = unlist(strsplit(i, "_"))[1]
  rslts[i, "census"]   = unlist(strsplit(i, "_"))[2]
    
  if (class(hv) == "Hypervolume"){
      
    rslts[i, "centroid_PC1"] = get_centroid(hv)[1]
    rslts[i, "centroid_PC2"] = get_centroid(hv)[2]
    rslts[i, "centroid_PC3"] = get_centroid(hv)[3]
    
    rslts[i, "volume"]       = hv@Volume

    rslts[i, "PC1_l"]         = min(hv@RandomPoints[,1])
    rslts[i, "PC1_h"]         = max(hv@RandomPoints[,1])
    rslts[i, "PC2_l"]         = min(hv@RandomPoints[,2])
    rslts[i, "PC2_h"]         = max(hv@RandomPoints[,2])
    rslts[i, "PC3_l"]         = min(hv@RandomPoints[,3])
    rslts[i, "PC3_h"]         = max(hv@RandomPoints[,3])

  }
}


rslts$plot_c = names


attributes <- read.csv("../Results/trees_sorted.csv")
a = as.data.frame(attributes %>% group_by(plot_c) %>% summarise(stem_C = sum(stem_C)))

rslts = merge(rslts, a, by = "plot_c", all.x = T)
