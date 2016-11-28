#!/usr/bin/env Rscript

# plot map of sampled site
EXPORT <- FALSE

library(sp) # SpatialPoints
library(raster) # raster
library(colorspace) # sequential_hcl
library(rasterVis) # rasterTheme, levelplot

# read in the base layer
tif_file <- file.path(data_dir, "ngdc_pug_snd_dm_subset.tif")

# read in the points
sites_file <- "sites.csv"
colname_lat <- "lat"
colname_lon <- "lon"

sites <- read.csv(
  file = file.path(data_dir, sites_file), 
  stringsAsFactors = FALSE
)

# exclude sites with no latitude data
sites <- sites[!is.na(sites$lat),]

# create bounding box
xleft  <- -122.84
xright <- -122.25
yupper <- 48.48
ylower <- 48.18

range_lon <- c(xleft,xright)
range_lat <- c(ylower, yupper)

pt_lon <- sites[,colname_lon]
pt_lat <- sites[,colname_lat]

# set points to add
mypoints <- SpatialPoints(cbind(pt_lon, pt_lat))

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
col_depth[length(col_depth)] <- "cornsilk3" # set the color of the land

# check the colors
# r <- raster(nrows=1, ncols= n_col)
# r <- setValues(r, 1:ncell(r))
# plot(r, col = col_depth)


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
  pdf(file = pdf_file, width = 6, height = 4)
}

par(mar = c(5,6,1,4))

myTheme <- rasterTheme(region = col_depth)
myTheme$add.line$col <- hsv(0,0.1,0.1, alpha = 0.2) # contour line colors
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
  mypoints[sites$net == "seine" & sites$indexed == "TRUE"], 
  col = "orangered", cex = 1, lwd = 2, pch = 1
))




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
