require(ggplot2)
require(ggpubr)
require(RColorBrewer)
source("00_functions.R")

load("../Results/plots/outputs_for_pres_plts.rda")

###############################################################################
# functions
###############################################################################

plot_hvs_3d <- function(hvs.rslts, plt){

    match_plt <- which(unlist(strsplit(names(hvs.rslts@hvlist), "_"))[c(T, F)] == plt)

    hvlist <- hvs.rslts@hvlist[match_plt]
    hvlist <- hvlist[which(!is.na(hvlist))]
    hvlist <- new("HypervolumeList", HVList = hvlist)

    plot(hvlist,
        show.3d = T,
        show.axes = F,
        show.frame = F,
        show.legend = F,
        names = c("","",""),
        cex.random     = 5,
        show.density   = T,
        point.alpha.min = 0.8,
        cex.centroid   = 300,
        cex.data       = 100,
        point.dark.factor = 0,
        colors = brewer.pal(max(c(length(match_plt), 3)), "Set2")
        )
}


movie3d <- function(f, duration, dev = rgl.cur(), ..., fps=10, 
                    movie = "movie", frames = movie, dir = tempdir(), 
                    convert = NULL, clean = TRUE, verbose=TRUE,
                    top = TRUE, type = "gif", startTime = 0) {
    
    orgdir <- getwd()
    olddir <- setwd(dir)
    on.exit(setwd(olddir))

    for (i in round(startTime*fps):(duration*fps)) {
	time <- i/fps        
	if(rgl.cur() != dev) rgl.set(dev)
	stopifnot(rgl.cur() != 0)
	args <- f(time, ...)
	subs <- args$subscene
	if (is.null(subs))
	    subs <- currentSubscene3d(dev)
	else
	    args$subscene <- NULL
	for (s in subs)
	    par3d(args, subscene = s)
	filename <- sprintf("%s%03d.png",frames,i)
	if (verbose) {
	    cat(gettextf("Writing '%s'\r", filename))
	    flush.console()
	}
        rgl.snapshot(filename=filename, fmt="png", top=top)
    }
  setwd(orgdir) 
  system(paste("bash make_mpeg.sh", movie, movie))
}



hv_movie <- function(hvs.rslts, plt, axis, image.size, rpm, dir, fps,
                       duration, name){

  plot_hvs_3d(hvs.rslts = hvs.rslts, plt = plt)
  par3d(windowRect=c(0,0,image.size,image.size))
  movie3d(spin3d(axis=axis,rpm=rpm), duration = duration, fps = fps, movie = name,
          frames = name, dir = dir, clean = FALSE)

}
 

###############################################################################
# hypervolume gifs
###############################################################################

make_movie = FALSE

if (make_movie == TRUE){

  hv_movie(trees_hvs_p, "Belian", axis = c(1, 1, 1), image.size = 1200, rpm = 4,
             dir = "../Results/plots/frames", fps = 20, duration = 15, name = "trees_belian")

  hv_movie(btles_hvs_p, "D", axis = c(1, 1, 0), image.size = 1200, rpm = 4,
             dir = "../Results/plots/frames", fps = 20, duration = 15, name = "btles_D")


  plot_hvs_3d(trees_hvs_p, "Belian")
  hypervolume_save_animated_gif(axis = c(1, 1, 1), image.size = 600, rpm = 4,
                                fps = 20, duration = 15, file.name = "trees_belian",
                                 directory.output = "../Results/plots/")

  plot_hvs_3d(btles_hvs_p, "D")
  hypervolume_save_animated_gif(axis = c(1, 1, 1), image.size = 600, rpm = 4,
                                fps = 20, duration = 15, file.name = "btles_D",
                                 directory.output = "../Results/plots/")
}

###############################################################################
# hypervolume plots
###############################################################################


# playing around to make the plots look pretty
plot_hvs <- function(hvs.rslts, plt){

    match_plt <- which(unlist(strsplit(names(hvs.rslts@hvlist), "_"))[c(T, F)] == plt)

    hvlist <- hvs.rslts@hvlist[match_plt]
    hvlist <- hvlist[which(!is.na(hvlist))]
    hvlist <- new("HypervolumeList", HVList = hvlist)

    plot(hvlist,
        contour.lwd    = 2,
        contour.type   = "kde",
        cex.random    = .8,
        cex.centroid  = 2,
        cex.data      = 1,
        cex.axis      = 1,
        point.dark.factor = 0,
        colors = brewer.pal(max(c(length(match_plt), 3)), "Set2")
        )
}


svg("../Results/plots/trees_belian_2d.svg", width = 10, height = 10)
plot_hvs(trees_hvs_p, "Belian")
dev.off()

svg("../Results/plots/btles_D_2d.svg", width = 10, height = 10)
plot_hvs(btles_hvs_p, "D")
dev.off()


###############################################################################
# actual proper plots
###############################################################################

# boxplot
bx_plt = ggplot(data = ovlp, aes(x = taxa, y = overlap, color = taxa, shape = taxa))
bx_plt = bx_plt + geom_boxplot()
bx_plt = bx_plt + geom_point(size = 2)
bx_plt = bx_plt + scale_color_brewer(palette = "Set2")
bx_plt = bx_plt + theme_classic()
bx_plt = bx_plt + theme(legend.title     = element_blank(),
                        legend.position  = "bottom",
                        axis.text        = element_text(size = 14),
                        axis.title.x     = element_text(size = 16, margin = margin(t = 20, unit = "pt")),
                        axis.title.y     = element_text(size = 16, margin = margin(r = 20, unit = "pt")),
                        legend.text      = element_text(size = 14, margin = margin(r = 24, unit = "pt")))
bx_plt = bx_plt + xlab("Taxa") + ylab("Hypervolume Overlap")

svg("../Results/plots/overlap_box.svg", width = 16, height = 9)
print(bx_plt)
dev.off()

# overlap by log(agb)
agb_plt = ggplot(data = ovlp, aes(x = logagb, y = overlap, color = taxa, shape = taxa))
agb_plt = agb_plt + geom_point(size = 2)
agb_plt = agb_plt + geom_smooth(method = 'lm', se = F)
agb_plt = agb_plt + scale_color_brewer(palette = "Set2")
agb_plt = agb_plt + theme_classic()
agb_plt = agb_plt + theme(legend.title     = element_blank(),
                          legend.position  = "bottom",
                          axis.text        = element_text(size = 14),
                          axis.title.x     = element_text(size = 16, margin = margin(t = 20, unit = "pt")),
                          axis.title.y     = element_text(size = 16, margin = margin(r = 20, unit = "pt")),
                          legend.text      = element_text(size = 14, margin = margin(r = 24, unit = "pt")))
agb_plt = agb_plt + xlab("log(AGB) / Mg/ha") + ylab("Hypervolume Overlap")

svg("../Results/plots/overlap_agb.svg", width = 16, height = 9)
print(agb_plt)
dev.off()

# boxplot
sbx_plt = ggplot(data = stab, aes(x = taxa, y = stability, color = taxa, shape = taxa))
sbx_plt = sbx_plt + geom_boxplot()
sbx_plt = sbx_plt + geom_point(size = 2)
sbx_plt = sbx_plt + scale_color_brewer(palette = "Set2")
sbx_plt = sbx_plt + theme_classic()
sbx_plt = sbx_plt + theme(legend.title     = element_blank(),
                          legend.position  = "bottom",
                          axis.text        = element_text(size = 14),
                          axis.title.x     = element_text(size = 16, margin = margin(t = 20, unit = "pt")),
                          axis.title.y     = element_text(size = 16, margin = margin(r = 20, unit = "pt")),
                          legend.text      = element_text(size = 14, margin = margin(r = 24, unit = "pt")))
sbx_plt = sbx_plt + xlab("Taxa") + ylab("log(Community Temporal Stability)")
  
svg("../Results/plots/stability_overlap_box.svg", width = 16, height = 9)
print(sbx_plt)
dev.off()

# overlap by log(agb)
sagb_plt = ggplot(data = stab, aes(x = logagb, y = stability, color = taxa, shape = taxa))
sagb_plt = sagb_plt + geom_point(size = 2)
sagb_plt = sagb_plt + scale_color_brewer(palette = "Set2")
sagb_plt = sagb_plt + geom_smooth(method = 'lm', se = F)
sagb_plt = sagb_plt + theme_classic()
sagb_plt = sagb_plt + theme(legend.title     = element_blank(),
                           legend.position  = "bottom",
                           axis.text        = element_text(size = 14),
                           axis.title.x     = element_text(size = 16, margin = margin(t = 20, unit = "pt")),
                           axis.title.y     = element_text(size = 16, margin = margin(r = 20, unit = "pt")),
                           legend.text      = element_text(size = 14, margin = margin(r = 24, unit = "pt")))
sagb_plt = sagb_plt + xlab("log(AGB) / Mg/ha") + ylab("log(Community Temporal Stability)")

svg("../Results/plots/stability_overlap_agb.svg", width = 16, height = 9)
print(sagb_plt)
dev.off()

plt = ggplot(data = ovlp_v_stab, aes(x = overlap, y = stability))
plt = plt + geom_point(aes(color = taxa, shape = taxa), size = 2)
plt = plt + scale_color_brewer(palette = "Set2")
plt = plt + theme_classic()
plt = plt + theme(legend.title     = element_blank(),
                  legend.position  = "bottom",
                  axis.text        = element_text(size = 14),
                  axis.title.x     = element_text(size = 16, margin = margin(t = 20, unit = "pt")),
                  axis.title.y     = element_text(size = 16, margin = margin(r = 20, unit = "pt")),
                  legend.text      = element_text(size = 14, margin = margin(r = 24, unit = "pt")))
plt = plt + theme(legend.position = "bottom", legend.title = element_blank())

svg("../Results/plots/correlation.svg", width = 16, height = 9)
plt = plt + xlab("Hypervolume Overlap") + ylab("log(Community Temporal Stability)")
dev.off()
