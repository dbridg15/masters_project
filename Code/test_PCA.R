


# require
require(vegan)
require(hypervolume)

# TODO

###############################################################################
#
###############################################################################

# read in species count matrix
a <- read.csv("../Results/trees_matrix.csv", header=T, row.names=1)
a[is.na(a)] <- 0
a <- as.matrix(a)

# make relative abundances matrix
a_rel <- t(apply(a, 1, function(x) x/sum(x)))


a <- metaMDS(a, k = 3, trymax = 100)
b <- metaMDS(a_rel, k = 3, trymax = 100)


test <- a$points


BNorth <- test[which(substr(row.names(test), 1, 7) == "B North"), ]
BSouth <- test[which(substr(row.names(test), 1, 7) == "B South"), ]
Belian <- test[which(substr(row.names(test), 1, 6) == "Belian"), ]

BNorth_hv <- hypervolume_svm(BNorth, name = "BNorth")
BSouth_hv <- hypervolume_svm(BSouth, name = "BSouth")


hypervolume_distance(BNorth_hv, BSouth_hv)

hvset <- hypervolume_set(BNorth_hv, BSouth_hv, check.memory=F)

hypervolume_overlap_statistics(hvset)
get_volume(hvset)

plot(hvset, show.3d=T, cex.centroid=15, cex.random=3, cex.data=5)

hypervolume_save_animated_gif(image.size = 2000, axis = c(0, 0, 1), rpm = 4,
                              duration = 15, fps = 25, file.name = "movie",
                              directory.output = ".")


