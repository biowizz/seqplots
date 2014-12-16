#' Wrapper function, plotting the heatmap
#' 
#' This function is package internal and should not be executed directly by
#' users.
#' 
#' @param MAT - list of matrixes holding heatmap data
#' @param axhline - locations of horizontal lines separating the clusters
#' @param titles the sub-titles of heatmaps
#' @param bins the x-axis indicates in heatmap
#' @param cex.axis Axis numbers font size in points, defaults to 12
#' @param cex.lab Axis labels font size in points, Defaults to 12
#' @param cex.legend Keys labels font size in points, defaults to 12
#' @param xlab label below x-axis
#' @param ylab label below y-axis
#' @param leg if TRUE plot the color key
#' @param autoscale if TRUE the color keys will be auto scaled
#' @param zmin global minimum value on color key, ignored if \code{autoscale} is
#'   TRUE
#' @param zmax global maximum value on color key, ignored if \code{autoscale} is
#'   TRUE
#' @param xlim the x limits (x1, x2) of the plot. Note that x1 > x2 is allowed
#'   and leads to a "reversed axis". The default value, NULL, indicates that the
#'   whole range present in \code{plotset} will be plotted.
#' @param ln.v Determines if vertical guide line(s) should be plotted (TRUE) or
#'   ommitted (FALSE). For anchored plots 2 lines indicating the start and end
#'   of anchored distance are plotted.
#' @param e Determines the end of anchored distance
#' @param s The saturation value used to auto scale color key limits, defaults
#'   to 0.01
#' @param indi If TRUE (defaults) the independent color keys will be plotted
#'   below heatmaps, if FALSE the common color key is shown rightmost
#' @param o_min vector of length equal to number of sub heatmaps determining
#'   minimum value on color key for each sub plot, if NULL (default) or NA the
#'   global settings are used, ignored in \code{indi} is FALSE
#' @param o_max vector of length equal to number of sub heatmaps determining
#'   maximum value on color key for each sub plot, if NULL (default) or NA the
#'   global settings are used, ignored in \code{indi} is FALSE
#' @param colvec The vector of colors used to plot the lines and error estimate
#'   fields. If set value NULL (default) the automatically generated color
#'   values will be used. Accepted values are: vector of any of the three kinds
#'   of R color specifications, i.e., either a color name (as listed by
#'   colors()), a hexadecimal string of the form "#rrggbb" or "#rrggbbaa" (see
#'   rgb), or a positive integer i meaning palette()[i]. See
#'   \code{\link[grDevices]{col2rgb}}.
#' @param colorspace The colorspace of the heatmap, see
#'   \code{\link[grDevices]{grDevices}}
#' @param pointsize The default font point size to be used for plots. Defaults
#'   to 12 (1/72 inch).
#'   
#' @return \code{NULL}
#'   
#' @keywords internal
#'   
ggHeatmapPlotWrapper <- function(MAT, axhline=NULL, titles=rep('', length(MAT)),
    bins=1:(ncol(MAT[[1]])/length(MAT)), cex.lab=12.0, cex.axis=12.0, 
    cex.legend=12.0, xlab='', ylab="", Leg=TRUE, autoscale=TRUE, zmin=0, 
    zmax=10, xlim=NULL, ln.v=TRUE, e=NULL, s = 0.01, indi=TRUE,
    o_min=NA, o_max=NA, colvec=NULL, colorspace=NULL, pointsize=12,
    embed=FALSE, ...) {
    
    lfs  <- cex.lab / pointsize
    afs  <- cex.axis / pointsize
    lgfs <- cex.legend / pointsize
    
    datapoints <- unlist(MAT)
    NP=length(MAT)
    raster <- length(unique(diff(bins)))==1
    
    #colvec[ grepl('#ffffff', colvec) ] <- NA
    ncollevel = 64
    if(length(colorspace)) {
        gcol <- colorRampPalette(colorspace)
    }else {
        gcol <- colorRampPalette(c(
            "#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow", 
            "#FF7F00", "red", "#7F0000"
        ))     
    }
    min <- min(datapoints, na.rm=TRUE)
    max <- max(datapoints, na.rm=TRUE) 
    
    if (!indi) {
        if (autoscale) {
            zlim <- quantile(datapoints, c(s,1-s), na.rm=TRUE)
            zmin<-zlim[1]
            zmax<-zlim[2]
        } 
#         if(!embed) 
#             layout(
#                 matrix(seq(NP+1), nrow=1, ncol=NP+1), 
#                 widths=c(rep(12/NP, NP), 1), heights=rep(1,NP+1)
#             )
        ColorRamp <-gcol(ncollevel)
        ColorLevels <- seq(to=zmax,from=zmin, length=ncollevel)#number sequence
    } else {
#        if(!embed) invisible(capture.output( set.panel(1, NP) ))
    }
    
    
    plots <- list()
    for (i in seq(NP)) {
        data <- MAT[[i]]
        

        xinds <- if (is.null(xlim)) range(bins) else xlim
        
        if( !indi ) {
            data[data<zmin] <- zmin
            data[data>zmax] <- zmax
            ColorRamp_ex <- ColorRamp[round( 
                (min(data, na.rm=TRUE)-zmin)*ncollevel/(zmax-zmin) ) : round( 
                    (max(data, na.rm=TRUE)-zmin)*ncollevel/(zmax-zmin) 
                )]
            image(
                bins, 1:nrow(data), t(data), axes=TRUE, col=ColorRamp_ex, 
                xlab=xlab, ylab=ylab, add=FALSE, #ylim=c(nrow(data),1),
                xlim=if (is.null(xlim)) range(bins) else xlim,
                cex=1, cex.main=lfs, cex.lab=lfs, cex.axis=afs,
                useRaster=raster, xaxt="n", panel.first={
                    if(is.null(e)) axis(1) 
                    else axis(
                        1, at=c(min(xinds), 0,  e, max(xinds)), 
                        labels=c(min(xinds), '0', '0', max(xinds)-e)
                    )
                    rect(
                        par("usr")[1],par("usr")[3],par("usr")[2],
                        par("usr")[4],col="lightgrey"
                    )
                }, ...
            )
            
        } else {
            if (autoscale) {
                zlim <- quantile(data, c(s,1-s), na.rm=TRUE)
                zmin<-zlim[1]
                zmax<-zlim[2]
            } 
            
            if( is.na(o_min[i]) ) data[data<zmin] <- zmin 
                else data[data<o_min[i]] <- o_min[i]
            if( is.na(o_max[i]) ) data[data>zmax] <- zmax 
                else data[data>o_max[i]] <- o_max[i]
            
            keycolor_lim <- range(data, na.rm=TRUE)
            if( is.na(o_min[i]) ) keycolor_lim[1] <- zmin 
                else keycolor_lim[1] <- o_min[i]
            if( is.na(o_max[i]) ) keycolor_lim[2] <- zmax 
                else keycolor_lim[2] <- o_max[i]
            
            col <- if( is.character(colvec[i]) ) 
                    colorRampPalette(c('white', colvec[i]))(ncollevel) 
                else gcol(ncollevel)
            
            #browser()
            colnames(data) <- bins
            p <- ggplot(melt(data), aes(Var2, Var1, fill = value)) + 
                geom_raster() + 
                scale_fill_gradientn(
                    colours = gcol(100), limits = keycolor_lim, 
                    breaks=keycolor_lim, labels=format(keycolor_lim, digits=2)
                ) +
                scale_x_continuous(
                    breaks=c(min(bins), 0, max(bins)),
                    labels=sapply(c(min(bins), 0, max(bins)), num2bp),
                    expand = c(0.05, 0.05)
                ) +
                geom_hline(yintercept=cumsum(axhline)[-length(axhline)]+.5, size=1) +
                geom_vline(xintercept=c(0, e), size=.75, colour='black') +
                scale_y_reverse(
                    #limits=if (is.null(xlim)) range(bins) else xlim,
                    breaks=c(cumsum(axhline)-(axhline/2)+.5, nrow(data)),
                    labels=c(paste0('C', 1:length(axhline)), nrow(data)),
                    expand = c(0.015, 0.015)
                ) +
                ggtitle(titles[i]) +
                xlab(xlab) +
                ylab(ylab) +
                theme(legend.position = "bottom") +
                guides(fill = guide_colorbar(barwidth = 10/5, barheight = 1, title = "", raster = TRUE))
            #dev.off()
            #labs(title = "New plot title", fill="")+
            
            plots[[i]] <- p
            
#             imPlot2(
#                 bins, 1:nrow(data), t(data), axes=TRUE, xlab=xlab, ylab=ylab, 
#                 xlim=if (is.null(xlim)) range(bins) else xlim,  
#                 zlim=keycolor_lim, col=col, #ylim=c(nrow(data),1),
#                 legend.width=1, horizontal=TRUE, useRaster=raster, 
#                 xinds=xinds, e=e, xaxt="n",
#                 cex=1, cex.main=lfs, cex.lab=lfs, cex.axis=afs, ...
#             )
            
#             axis(1)
            
            
            
        }
#         title( main=titles[i]); box()
#         if (!is.null(axhline)){
#             message(paste(axhline, collapse=', '))
#             abline(h=cumsum(axhline)+.5, lwd=4)
#             axis(4, at=cumsum(axhline)-(axhline/2)+.5, labels=1:length(axhline))
#             #cumsum(axhline)
#          
#         }
#         if (ln.v){
#             abline(v=c(0, e), lwd=2)
#         }
#         
#         if(embed) break()
    }

    do.call(grid.arrange, c(
        plots, ncol=length(plots), main="The Heatmap", clip=FALSE, legend='zzzz'
    ))
    #draw legend/color key for multiple heatmaps
    if(Leg & !indi & !embed) {
        opar <- par()[c('cex.axis', 'mar')]; par(cex.axis=lgfs, mar=c(0,0,0,0));
        plot.new(); 
        image.plot(
            1, ColorLevels, 
            matrix(data=ColorLevels, ncol=length(ColorLevels),nrow=1),
            col=ColorRamp, legend.only = TRUE, legend.shrink=1, 
            smallplot=c(.01,.25,0.3,.8)
        )
        par(opar)
    }
    #if(!embed) layout(1)
}