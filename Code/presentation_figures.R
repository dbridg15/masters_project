require(ggplot2)
require(ggpubr)
require(RColorBrewer)
source("00_functions.R")

load("../Results/plots/outputs_for_pres_plts.rda")


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


plot_hvs(trees_hvs_p, "Belian")


plot_hvs(btles_hvs_p, "D")

hypervolume_save_animated_gif(file.name = "test", directory.output = "../Results/plots/")


play3d(spin3d(axis=c(1, 1, 0)))

movie3d(spin3d(axis=c(1, 1, 0) , rpm = 4), duration = 15, fps = 10, 
                    movie = "movie", dir = "../Results/plots/", clean = F)

rgl.snapshot("../Results/plots/test.png")

hypervolume_save_animated_gif <- function(image.size=400, axis=c(0,0,1),
                                          rpm=4,duration=15,fps=10,
                                          file.name='movie',directory.output='.',...)
{
  td = tempdir()
  tf = basename(tempfile(tmpdir=td))
  
  rgl::par3d(windowRect=c(100,100,500,500))
  rgl::movie3d(spin3d(axis=axis,rpm=rpm),duration=duration,fps=fps,movie=tf,dir=td,...)
  
  if(!file.exists(directory.output))
  {
    dir.create(directory.output)
  }
  file.rename(sprintf("%s.gif",file.path(td,tf)),file.path(directory.output,sprintf("%s.gif",file.name)))
}
