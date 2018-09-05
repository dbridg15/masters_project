require(ggplot2)
require(ggpubr)
require(RColorBrewer)
source("00_functions.R")

load("../Results/plots/outputs_for_pres_plts.rda")

###############################################################################
# functions
###############################################################################

plot_hvs <- function(hvs.rslts, plt){

    match_plt <- which(unlist(strsplit(names(hvs.rslts@hvlist), "_"))[c(T, F)] == plt)

    hvlist <- hvs.rslts@hvlist[match_plt]
    hvlist <- hvlist[which(!is.na(hvlist))]
    hvlist <- new("HypervolumeList", HVList = hvlist)

    plot(hvlist,
        show.3d = T,
        #contour.lwd    = 1,
        #contour.type   = "kde",
        #show.centroid = T,
        #show.density = T,
        #show.random   = T,
        cex.random     = 5,
        show.density   = T,
        point.alpha.min = 0.8,
        cex.centroid   = 300,
        cex.data       = 100,
        #cex.axis      = 1,
        point.dark.factor = 0,
        colors = brewer.pal(max(c(length(match_plt), 3)), "Set2")
        )
    return(hvlist)
}


movie3d <- function(f, duration, dev = rgl.cur(), ..., fps=10, 
                    movie = "movie", frames = movie, dir = tempdir(), 
                    convert = NULL, clean = TRUE, verbose=TRUE,
                    top = TRUE, type = "gif", startTime = 0) {
    
    #olddir <- setwd(dir)
    #on.exit(setwd(olddir))
    olddir <- getwd()

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
  setwd(olddir) 
  system(paste("bash make_mpeg.sh", name, name))
}



make_movie <- function(hvs.rslts, plt, axis, image.size, rpm, dir, fps,
                       duration, name){

  plot_hvs(hvs.rslts = hvs.rslts, plt = plt)
  par3d(windowRect=c(0,0,image.size,image.size))
  movie3d(spin3d(axis=axis,rpm=rpm), duration = duration, fps = fps, movie = name,
          frames = name, dir = dir, clean = FALSE)

}
 

###############################################################################
# plots
###############################################################################

make_movie(trees_hvs_p, "Belian", axis = c(1, 1, 0), image.size = 1200, rpm = 4,
           dir = "../Results/plots/frames", fps = 20, duration = 15, name = "trees_belian")
