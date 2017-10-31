#!/usr/bin/env Rscript

# plot map of sampled site
EXPORT <- FALSE

library(sp) # SpatialPoints
library(raster) # raster
library(colorspace) # sequential_hcl
library(rasterVis) # rasterTheme, levelplot
library(rgdal)
library(grid)
library(geosphere)

# specify in the base layer
tif_file <- file.path(data_dir, "ngdc_pug_snd_dm_subset.tif")

# specify in the sites file
sites_file <- "sites.csv"
sites <- load_sites(sites_file)

# exclude sites with no latitude data
sites <- sites[!is.na(lat),]

# create bounding box
xleft  <- -122.65
xright <- -122.25
yupper <- 48.48
ylower <- 48.25

range_lon <- c(xleft,xright)
range_lat <- c(ylower, yupper)

pt_lon <- sites[,lon]
pt_lat <- sites[,lat]

# set points to add
mypoints <- SpatialPoints(cbind(pt_lon, pt_lat))

# read in the map layer
data_raster <- raster(tif_file)

# convert from decimeters to meters
data_raster <- data_raster/10

ignore_above <- function(x, lev){
# convert any values of a vector that are > 0 to 0
  x[ x > lev ] <- 0
  return(x)
}

# ignore elevation above sea level
data_raster <- ignore_above(data_raster, -1)

# create clipping polygon
CP <- extent(c(range_lon, range_lat))

# crop raster
data_raster <- crop(data_raster, CP)

n_col <- 10

col_depth <- sequential_hcl(n_col, 
  h = 260, 
  c. = c(60, 30), 
  l = c(20, 70), 
  power = 1, gamma = NULL, fixup = TRUE, alpha = 1)

# set the color of the land was cornsilk3
# match_ppt_map <- rgb(203, 226, 188, maxColorValue = 255)
col_depth[length(col_depth)] <- 'cornsilk3'

# check the colors
# r <- raster(nrows=1, ncols= n_col)
# r <- setValues(r, 1:ncell(r))
# plot(r, col = col_depth)

col_depth_alt <- diverge_hcl(n_col, 
  h = c(260, 60), 
  c = c(60, 30), 
  l = c(20, 70), 
  power = 1, gamma = NULL, fixup = TRUE, alpha = 1)

# check the colors
# r <- raster(nrows=1, ncols= n_col)
# r <- setValues(r, 1:ncell(r))
# plot(r, col = col_depth_alt)


#-------------------------------------------------------------------------------
# PLOTTING
plot_name   <- "site_map"

if(!exists("legend_text")){legend_text <- list()}

legend_text[plot_name] <- {
"Map of study area. 
Depth in meters below sea level is indicated by shading and 25 meter contours.
Sampled locations are indicated by red points."
}

if(EXPORT){
  pdf_file    <- file.path(fig_dir, paste(plot_name, ".pdf", sep = ""))
  legend_file <- file.path(fig_dir, paste(plot_name, "_legend.txt", sep = ""))
  writeLines(legend_text[[plot_name]], con = legend_file)
  pdf(file = pdf_file, width = 6, height = 4.5)
}

# par(mar = c(5,6,1,4)) # this doesn't appear to work with grid graphics

myTheme <- rasterTheme(region = col_depth)
myTheme$add.line$col <- hsv(0,0.1,0.1, alpha = 0.2) # contour line colors

Narrow_pos <- c(
  x = xmin(data_raster) + 0.95*(xmax(data_raster) - xmin(data_raster)),
  y = ymin(data_raster) + 0.9*(ymax(data_raster) - ymin(data_raster))
)

scale_start <- -122.35
scale_y <- 48.47
scale_length_m <- 5000
scale_segments <- 5
scale_breaks <- seq(from = 0, to = scale_length_m, 
  length.out = scale_segments + 1)
x_scale <- destPoint(p = c(scale_start, scale_y), b = 90, 
  d = scale_breaks)
scale_labels <- c("km", as.character(scale_breaks[-1] / 1000))

levelplot(
  x = data_raster, 
  margin = FALSE, contour = TRUE, 
  par.settings = myTheme
) + 
layer(sp.points(
  mypoints[sites$net == "fyke"], 
  col = "orangered", cex = 1, lwd = 2, pch = 2
)) +
layer(sp.points(
  mypoints[sites$net == "seine" & sites$revisit == "index"], 
  col = "orangered", cex = 1, lwd = 2, pch = 1
)) + 
layer({
  # North Arrow
  SpatialPolygonsRescale(layout.north.arrow(type = 2), 
    offset = c(Narrow_pos["x"], Narrow_pos["y"]), 
    col = "black", fill = grey(0), 
    scale = 0.02
  )
  grid.text(
    label = "N", 
    x = Narrow_pos["x"], y = Narrow_pos["y"], 
    gp = gpar(cex = 1.2, col = "black"), 
    hjust = 0.2, vjust = 1, 
    default.units = 'native'
  )
}) + 
layer({
  # Scale Bar
  grid.rect(x = x_scale[-1,1], y = scale_y, 
    width = diff(x_scale[,1]), height = 0.001, 
    gp = gpar(fill = rep(c('white', 'black') , 2)), 
    default.units = 'native'
  )
  grid.text(
    x = x_scale[,1], y = scale_y, label = scale_labels,
    gp = gpar(cex = 0.5), rot = 0, vjust = -0.5,
    default.units = 'native'
  )
})
# depth legend
ck <- seekViewport("plot_01.legend.right.vp")
grid.text("Depth \n(m)", x = unit(0, "npc"), y = unit(0, "npc"), 
          # just = c("left", "top"), 
          hjust = 0, vjust = 1.5,
          gp = gpar(cex = 0.9))

if(EXPORT){
  dev.off()
}

# plot raster arguments:
# function (x, col, add = FALSE, legend = TRUE, horizontal = FALSE, 
#     legend.shrink = 0.5, legend.width = 0.6, legend.mar = ifelse(horizontal, 
#         3.1, 5.1), legend.lab = NULL, graphics.reset = FALSE, 
#     bigplot = NULL, smallplot = NULL, legend.only = FALSE, lab.breaks = NULL, 
#     axis.args = NULL, legend.args = NULL, interpolate = FALSE, 
#     box = TRUE, breaks = NULL, zlim = NULL, zlimcol = NULL, fun = NULL, 
#     asp, colNA = NA, ...)
