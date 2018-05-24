#!usr/bin/env Rscript

# script: test_PCA.R 
# Desc:   
# Author: David Bridgwood (dmb2417@ic.ac.uk)

# require

###############################################################################
#
###############################################################################

# overall dataframe from species ordination
all_df         <- as.data.frame(count_mds$points)
all_df$plot    <- unlist(strsplit(row.names(df), "_"))[ c(T,F,F)]
all_df$subplot <- unlist(strsplit(row.names(df), "_"))[ c(F,T,F)]
all_df$census  <- unlist(strsplit(row.names(df), "_"))[ c(F,F,T)]

# plot dataframes
bnorth_df <- subset(all_df, plot == "BNorth")
bsouth_df <- subset(all_df, plot == "BSouth")
belian_df <- subset(all_df, plot == "Belian")
dc1_df    <- subset(all_df, plot == "DC1")
dc2_df    <- subset(all_df, plot == "DC2")
e_df      <- subset(all_df, plot == "E")
lf_df     <- subset(all_df, plot == "LF")
seraya_df <- subset(all_df, plot == "Seraya")
tower_df  <- subset(all_df, plot == "Tower")

# plots compare census
bnorth_cc <- compare_census(df = bnorth_df, compare = "census", type = "svm", plot = TRUE)
bsouth_cc <- compare_census(df = bsouth_df, compare = "census", type = "svm", plot = TRUE)
belian_cc <- compare_census(df = belian_df, compare = "census", type = "svm", plot = TRUE)
dc1_cc    <- compare_census(df = dc1_df   , compare = "census", type = "svm", plot = TRUE)
dc2_cc    <- compare_census(df = dc2_df   , compare = "census", type = "svm", plot = TRUE)
e_cc      <- compare_census(df = e_df     , compare = "census", type = "svm", plot = TRUE)
lf_cc     <- compare_census(df = lf_df    , compare = "census", type = "svm", plot = TRUE)
seraya_cc <- compare_census(df = seraya_df, compare = "census", type = "svm", plot = TRUE)
tower_cc  <- compare_census(df = tower_df , compare = "census", type = "svm", plot = TRUE)

# census dataframes
c1_df <- subset(all_df, census == "c1") 
c2_df <- subset(all_df, census == "c2") 
c3_df <- subset(all_df, census == "c3") 
c4_df <- subset(all_df, census == "c4") 

# census compare plots
c1_cp <- compare_hypervolumes(df = c1_df, compare = "plot", type = "svm", plot = TRUE)
c2_cp <- compare_hypervolumes(df = c2_df, compare = "plot", type = "svm", plot = TRUE)
c3_cp <- compare_hypervolumes(df = c3_df, compare = "plot", type = "svm", plot = TRUE)
c4_cp <- compare_hypervolumes(df = c4_df, compare = "plot", type = "svm", plot = TRUE)




hv1 = bnorth_cc@hvlist[[1]]
hv2 = bnorth_cc@hvlist[[2]]

invisible(hypervolume_set(hv1, hv2, check.memory = F))
