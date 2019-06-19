## ----echo = FALSE--------------------------------------------------------
knitr::opts_chunk$set(fig.width=10, fig.align = "center")


## ---- echo = FALSE-------------------------------------------------------
rf<-data.frame(raster::writeFormats())

rf <- rf[rf$name %in% c("raster","BIL","ascii","GTiff","netCDF"),]
rf$extension <- c(".grd",".bil",".asc",".tiff",".nc")
names(rf)<-c("Name","Long Name","File Extension")
rf


## ----load-raster, message = FALSE, error = FALSE, warning = FALSE--------
# load library
library(raster)


## ----empty-raster--------------------------------------------------------
# Create a raster from scratch using raster
firstRaster <- raster(xmn = -100,   # set minimum x coordinate
                      xmx = -60,    # set maximum x coordinate
                      ymn = 25,     # set minimum y coordinate
                      ymx = 50,     # set maximum y coordinate
                      res = c(1,1)) # resolution in c(x,y) direction


## ----raster-data---------------------------------------------------------
# Take a look at what the raster looks like
firstRaster


## ----set-values-raster---------------------------------------------------
# Assign values to raster 
firstRaster[] <- seq(from = 1, to = ncell(firstRaster),by = 1)

# Take a look at the raster now
firstRaster


## ----plot-raster-1-------------------------------------------------------
plot(firstRaster)


## ------------------------------------------------------------------------
# read in raster layer using raster function
# NDVI <- raster("path/to/raster/file")
NDVI <- raster::raster("../Spatial_Layers/MOD_NDVI_M_2018-01-01_rgb_3600x1800.FLOAT.TIFF")


## ------------------------------------------------------------------------
NDVI


## ---- echo = FALSE-------------------------------------------------------
par(bty="n",mar = c(0,0,0,3))
plot(NDVI, axes = FALSE)


## ---- echo = FALSE,warning = FALSE,message = FALSE-----------------------
# First option for making NDVI appear as expected
# set values larger than 2 to NA 
#NDVI[NDVI>2]<-NA
par(bty = "n",mar = c(0,0,2,3))
#plot(NDVI, axes = FALSE)

# Second option - leave NDVI values intact but
# only plot values within the range of 'normal' 
# NDVI values c(-0.1,0.9)
raster::plot(NDVI, axes = FALSE, zlim = c(-0.1,0.9), legend.args=list("NDVI"))

