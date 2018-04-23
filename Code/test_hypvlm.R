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
                                  kde.bandwidth = bandwidth, name = "Logged")

hv_oldgrw <- hypervolume_gaussian(oldgrw[, c("avghgtnorm", "tbiomcnorm", "simpdv")],
                                  kde.bandwidth = bandwidth, name = "Oldgrw")


# use hypervolume_svm when you think the extremes of the data represent the
# true bounds
hv_logged <- hypervolume_svm(logged[, c("avghgtnorm", "tbiomcnorm", "simpdv")],
                             name = "Logged")

hv_oldgrw <- hypervolume_svm(oldgrw[, c("avghgtnorm", "tbiomcnorm", "simpdv")],
                             name = "Oldgrw")



hypervolume_distance(hv_logged, hv_oldgrw)

hvset <- hypervolume_set(hv_logged, hv_oldgrw, check.memory=F)

hypervolume_overlap_statistics(hvset)
get_volume(hvset)

plot(hvset, show.3d=T, cex.centroid=15, cex.random=3, cex.data=5)

# save 3d plot as a gif...
# hypervolume_save_animated_gif(image.size = 400, axis = c(0, 0, 1), rpm = 4,
#                               duration = 15, fps = 10, file.name = "movie",
#                               directory.output = ".")


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

