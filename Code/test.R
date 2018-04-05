require(hypervolume)

df <- read.csv("../Results/trees_sorted.csv")

BNorth_1 <- df[which(df$plot == 'B North' & df$census == 1), ]
BNorth_2 <- df[which(df$plot == 'B North' & df$census == 2), ]
BNorth_3 <- df[which(df$plot == 'B North' & df$census == 3), ]
BNorth_4 <- df[which(df$plot == 'B North' & df$census == 4), ]

hv1  <- hypervolume_gaussian(BNorth_1[ , c("height", "d_pom", "stem_C")])
hv2  <- hypervolume_gaussian(BNorth_2[ , c("height", "d_pom", "stem_C")])
hv3  <- hypervolume_gaussian(BNorth_3[ , c("height", "d_pom", "stem_C")])
hv4  <- hypervolume_gaussian(BNorth_4[ , c("height", "d_pom", "stem_C")])

hv_set <- hypervolume_set(hv1, hv2, check.memory = FALSE)

hypervolume_overlap_statistics(hv_set)

hypervolume_distance(hv1, hv2)

plot(hv2, show.3d = TRUE)

###############################################################################
# logged vs old-growth
###############################################################################

logged <- df[which(df$f_type == 'Logged'), ]
oldgrw <- df[which(df$f_type == 'Old-growth'), ]

hv_logged <- hypervolume_gaussian(logged[ , c("height", "d_pom", "stem_C")])
hv_oldgrw <- hypervolume_gaussian(oldgrw[ , c("height", "d_pom", "stem_C")])
