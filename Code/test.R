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

df <- read.csv("../Results/tree_axis.csv")

bandwidth = estimate_bandwidth(df[, c("avghgtnorm", "tbiomcnorm", "simpdv")]) 

census = 1

logged <- df[which(df$f_type == 'Logged' & df$census == census), ]
oldgrw <- df[which(df$f_type == 'Old-growth' & df$census == census), ]


hv_logged <- hypervolume_gaussian(logged[, c("avghgtnorm", "tbiomcnorm", "simpdv")],
                                  kde.bandwidth = bandwidth)

hv_oldgrw <- hypervolume_gaussian(oldgrw[, c("avghgtnorm", "tbiomcnorm", "simpdv")],
                                  kde.bandwidth = bandwidth)


###############################################################################
# trying for plots...
###############################################################################

plt <- "B North"

sbst <- subset(df, plot == plt)

cn1 <- subset(sbst, census == 1)
cn2 <- subset(sbst, census == 2)
cn3 <- subset(sbst, census == 3)
cn4 <- subset(sbst, census == 4)

cn1_hv <- hypervolume_gaussian(cn1[, c("avghgtnorm", "tbiomcnorm", "simpdv")],
                               kde.bandwidth = bandwidth)
cn2_hv <- hypervolume_gaussian(cn2[, c("avghgtnorm", "tbiomcnorm", "simpdv")],
                               kde.bandwidth = bandwidth)
cn3_hv <- hypervolume_gaussian(cn3[, c("avghgtnorm", "tbiomcnorm", "simpdv")],
                               kde.bandwidth = bandwidth)
cn4_hv <- hypervolume_gaussian(cn4[, c("avghgtnorm", "tbiomcnorm", "simpdv")],
                               kde.bandwidth = bandwidth)





















