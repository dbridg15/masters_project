require(ggplot2)
require(ggpubr)
require(RColorBrewer)
source("00_functions.R")


###############################################################################
# read in data
###############################################################################

# abundance
trees_df = read.csv("../Results/trees_matrix.csv", row.names=1)
#trees_df = read.csv("../Results/trees_genus_matrix.csv", row.names=1)
mamls_df = read.csv("../Results/m_trap-year.csv", row.names=1)
btles_df = read.csv("../Results/btles_matrix.csv", row.names=1)

# time between censuses
trees_cen = read.csv("../Results/trees_census_dates.csv")
btles_cen = read.csv("../Results/btles_census_dates.csv")
mamls_cen = read.csv("../Results/mamls_years_dates.csv")


###############################################################################
# do the things!
###############################################################################

# PCA
scale = F

trees_pca = do_pca(trees_df, scale = scale, plot = F)
mamls_pca = do_pca(mamls_df, scale = scale, plot = F)
btles_pca = do_pca(btles_df, scale = scale, plot = F)

cat("Explained Varience Trees (first 3 PCs):", sum(trees_pca@exp.var[0:3])*100)
trees_pca@exp.var[0:5]
cat("Explained Varience Mammals (first 3 PCs):", sum(mamls_pca@exp.var[0:3])*100)
mamls_pca@exp.var[0:5]
cat("Explained Varience Beetles: (first 3 PCs)", sum(btles_pca@exp.var[0:3])*100)
btles_pca@exp.var[0:5]


# construct and compare hypervolumes
trees_hvs_p = hvs_rslts(trees_pca@axis, axis = c("PC1", "PC2", "PC3"), "seq", trees_cen, method = "gaussian")
mamls_hvs_p = hvs_rslts(mamls_pca@axis, axis = c("PC1", "PC2", "PC3"), "seq", mamls_cen, method = "gaussian")
btles_hvs_p = hvs_rslts(btles_pca@axis, axis = c("PC1", "PC2", "PC3"), "seq", btles_cen, method = "gaussian")


###############################################################################
# plot the things!
###############################################################################

# playing around to make the plots look pretty
plot_hvs <- function(hvs.rslts, plt){

    match_plt <- which(unlist(strsplit(names(hvs.rslts@hvlist), "_"))[c(T, F)] == plt)

    hvlist <- hvs.rslts@hvlist[match_plt]
    hvlist <- hvlist[which(!is.na(hvlist))]
    hvlist <- new("HypervolumeList", HVList = hvlist)

    plot(hvlist,
        #contour.lwd    = 1,
        contour.type   = "kde",
        #show.centroid = F,
        #show.density = T,
        #cex.centroid  = 2,
        cex.random    = 0.3,
        cex.centroid  = 2.5,
        cex.data      = 1,
        cex.axis      = 1,
        point.dark.factor = 0.2,
        colors = brewer.pal(max(c(length(match_plt), 3)), "Set2")
        )
}


pdf("../Thesis/Writing/figures/figure1a.pdf", width = 10, height = 10)
plot_hvs(trees_hvs_p, "Belian")
dev.off()

pdf("../Thesis/Writing/figures/figure1b.pdf", width = 10, height = 10)
plot_hvs(btles_hvs_p, "D")
dev.off()


##############################################################################3
# overlap
###############################################################################

kind = "pca"

# set up dataframe for plotting
trees_agb = read.csv("../Results/trees_agb.csv")
btles_agb = read.csv("../Results/btles_agb.csv")
mamls_agb = read.csv("../Results/mamls_agb.csv")

if(kind == "pca"){
    btles = btles_hvs_p@compare
    trees = trees_hvs_p@compare
    mamls = mamls_hvs_p@compare
    } else if (kind == "zifa"){
    btles = btles_hvs_z@compare
    trees = trees_hvs_z@compare
    mamls = mamls_hvs_z@compare
    } else {cat("kind not defined")}

    
btles$taxa = "Beetles"
colnames(btles_agb) = c("plot", "agb")
btles = merge(btles, btles_agb, by = "plot")

trees$taxa = "Trees"
colnames(trees_agb) = c("plot", "agb")
trees = merge(trees, trees_agb, by = "plot")

mamls$taxa = "Mammals"
colnames(mamls_agb) = c("plot", "agb")
mamls = merge(mamls, mamls_agb, by = "plot")

ovlp = rbind(trees, btles, mamls)
ovlp = ovlp[complete.cases(ovlp), ]
ovlp$taxa = as.factor(ovlp$taxa)

ovlp$agb = ovlp$agb*16
ovlp$logagb = log(ovlp$agb)


# boxplot
bx_plt = ggplot(data = ovlp, aes(x = taxa, y = overlap, color = taxa, shape = taxa))
bx_plt = bx_plt + geom_boxplot()
bx_plt = bx_plt + geom_point(alpha = 0.5)
bx_plt = bx_plt + scale_color_brewer(palette = "Set2")
bx_plt = bx_plt + theme_classic()
bx_plt = bx_plt + theme(legend.position="none")
bx_plt = bx_plt + xlab("Taxa") + ylab("Hypervolume Overlap")
#print(bx_plt)


# overlap by log(agb)
agb_plt = ggplot(data = ovlp, aes(x = logagb, y = overlap, color = taxa, shape = taxa))
agb_plt = agb_plt + geom_point()
agb_plt = agb_plt + scale_color_brewer(palette = "Set2")
agb_plt = agb_plt + theme_classic()
agb_plt = agb_plt + theme(legend.position="bottom", legend.title = element_blank())
agb_plt = agb_plt + xlab("log(AGB) / Mg/ha") + ylab("Hypervolume Overlap")
#print(agb_plt)



###############################################################################
# spatial stabiltiy
###############################################################################

# readin and sort data
trees_df = read.csv("../Results/trees_matrix.csv", row.names=1)
mamls_df = read.csv("../Results/m_trap-year.csv", row.names=1)
btles_df = read.csv("../Results/btles_matrix.csv", row.names=1)

trees_df = add_cols(trees_df)
mamls_df = add_cols(mamls_df)
btles_df = add_cols(btles_df)

trees = melt(trees_df, id.vars=c("plot", "subplot", "census"))
mamls = melt(mamls_df, id.vars=c("plot", "subplot", "census"))
btles = melt(btles_df, id.vars=c("plot", "subplot", "census"))


# calculate stability
trees_stb = spatial_stability(trees)
mamls_stb = spatial_stability(mamls)
btles_stb = spatial_stability(btles)

trees_stb$taxa = "Trees"
mamls_stb$taxa = "Mammals"
btles_stb$taxa = "Beetles"

trees_stb$plot = unlist(strsplit(trees_stb$census, "_"))[ c(T,F)]
mamls_stb$plot = unlist(strsplit(mamls_stb$census, "_"))[ c(T,F)]
btles_stb$plot = unlist(strsplit(btles_stb$census, "_"))[ c(T,F)]


 #merge with agb
trees_agb = read.csv("../Results/trees_agb.csv")
btles_agb = read.csv("../Results/btles_agb.csv")
mamls_agb = read.csv("../Results/mamls_agb.csv")

colnames(trees_agb) = c("plot", "agb")
colnames(mamls_agb) = c("plot", "agb")
colnames(btles_agb) = c("plot", "agb")

trees_stb = merge(trees_stb, trees_agb, by = "plot")
mamls_stb = merge(mamls_stb, mamls_agb, by = "plot")
btles_stb = merge(btles_stb, btles_agb, by = "plot")


# setup dataframe for plotting
stab = rbind(trees_stb, btles_stb, mamls_stb)
stab = stab[complete.cases(stab), ]
stab$taxa = as.factor(stab$taxa)

stab$agb = stab$agb*16
stab$logagb = log(stab$agb)

# boxplot
sbx_plt = ggplot(data = stab, aes(x = taxa, y = stability, color = taxa, shape = taxa))
sbx_plt = sbx_plt + geom_boxplot()
sbx_plt = sbx_plt + geom_point(alpha = 0.5)
sbx_plt = sbx_plt + scale_color_brewer(palette = "Set2")
sbx_plt = sbx_plt + theme_classic()
sbx_plt = sbx_plt + theme(legend.position="none")
sbx_plt = sbx_plt + xlab("Taxa") + ylab("Community Spatial Stability")
#print(sbx_plt)


# overlap by log(agb)
sagb_plt = ggplot(data = stab, aes(x = logagb, y = stability, color = taxa, shape = taxa))
sagb_plt = sagb_plt + geom_point()
sagb_plt = sagb_plt + scale_color_brewer(palette = "Set2")
sagb_plt = sagb_plt + geom_smooth(method = lm, se = F, data = subset(stab, taxa == "Trees"))
sagb_plt = sagb_plt + theme_classic()
sagb_plt = sagb_plt + theme(legend.position="bottom", legend.title = element_blank())
sagb_plt = sagb_plt + xlab("log(AGB) / Mg/ha") + ylab("Community Spatial Stability")
#print(sagb_plt)


###############################################################################
# group plot
###############################################################################

pdf("../Thesis/Writing/figures/figure2.pdf", width =11.69, height=8.27)
par(mar = c(0.5,1,0.5,1))
ggarrange(bx_plt, sbx_plt, agb_plt, sagb_plt, labels = c("A", "C", "B", "D"),
          ncol = 2, nrow = 2, hjust = -1, vjust = 2)
dev.off()
 


###############################################################################
#
###############################################################################


###############################################################################
#
###############################################################################

# compare hypervolume-overlap with spatial-stability

a = ovlp %>% 
  group_by(plot, taxa) %>% summarise(overlap = mean(overlap))

b = stab %>% 
	group_by(plot, taxa) %>% summarise(stability = mean(stability))

c = merge(a, b, by = c("plot", "taxa"))

plt = ggplot(data = c, aes(x = overlap, y = stability, color = taxa, shape = taxa))
plt = plt + geom_point()
plt = plt + geom_smooth(method = 'lm', se = F)
print(plt)
