## ----warning = FALSE, error = FALSE, message = FALSE---------------------
library(raster)
library(sp)
library(ks)

## ------------------------------------------------------------------------
OVEN_locs <- read.csv("../Spatial_Layers/OVEN_2012_locs.csv")

## ----echo = FALSE--------------------------------------------------------
str(OVEN_locs)

## ------------------------------------------------------------------------
# coords = cbind(long,lat)
# crs = WGS84 
OVENpts <- sp::SpatialPoints(coords = cbind(OVEN_locs$long,OVEN_locs$lat),
                             proj4string = sp::CRS("+init=epsg:4326"))

# take a peek
head(OVENpts)

## ------------------------------------------------------------------------
OVEN_spdf <- sp::SpatialPointsDataFrame(OVENpts,OVEN_locs)

head(OVEN_spdf)

## ------------------------------------------------------------------------
OVEN_sep <- split(x = OVEN_spdf, f = OVEN_spdf$Bird, drop = FALSE)

## ------------------------------------------------------------------------
OVENmcp <- lapply(OVEN_sep, FUN = function(x){rgeos::gConvexHull(x)})

## ------------------------------------------------------------------------
OVENmcp <- mapply(OVENmcp, names(OVENmcp), 
                  SIMPLIFY = FALSE,
                  FUN = function(x,y){x@polygons[[1]]@ID <- y
                  return(x)})

## ------------------------------------------------------------------------
OVENmcp <- do.call(rbind,OVENmcp)

## ----echo = FALSE--------------------------------------------------------
OVENmcp

## ------------------------------------------------------------------------
OVENmcp <- SpatialPolygonsDataFrame(Sr = OVENmcp,
                                    data = data.frame(Bird = names(OVENmcp)),
                                    match.ID = FALSE)

## ---- echo = FALSE-------------------------------------------------------
OVENmcp

## ---- echo = FALSE-------------------------------------------------------
# This chunck creates a plot
# Generate colors 
genCols <- colorRampPalette(c(rgb(0,0,0,0.5),
                              rgb(0.1,0.1,0.9,0.5),
                              rgb(0.9,0.9,0,0.5)),
                              alpha = TRUE)

# generate x colors 
cols <- genCols(length(OVENmcp))

plot(OVENmcp, col = cols)

## ------------------------------------------------------------------------
bw <- lapply(OVEN_sep, FUN = function(x){ks::Hlscv(x@coords)})

## ------------------------------------------------------------------------
OVEN_kde <-mapply(OVEN_sep,bw,
                  SIMPLIFY = FALSE,
                  FUN = function(x,y){
                   raster(kde(x@coords,h=y))})

## ----echo = FALSE--------------------------------------------------------
plot(OVEN_kde[[1]])
plot(OVENmcp[1,],add = TRUE)

## ------------------------------------------------------------------------
# This code makes a custom function called getContour. 
# Inputs:
#    kde = kernel density estimate
#    prob = probabily - default is 0.95

getContour <- function(kde, prob = 0.95){
   # set all values 0 to NA
      kde[kde == 0]<-NA
   # create a vector of raster values
      kde_values <- raster::getValues(kde)
   # sort values 
      sortedValues <- sort(kde_values[!is.na(kde_values)],decreasing = TRUE)
   # find cumulative sum up to ith location
      sums <- cumsum(as.numeric(sortedValues))
   # binary response is value in the probabily zone or not
      p <- sum(sums <= prob * sums[length(sums)])
   # Set values in raster to 1 or 0
      kdeprob <- raster::setValues(kde, kde_values >= sortedValues[p])
   # return new kde
      return(kdeprob)
}

## ------------------------------------------------------------------------
OVEN_95kde <- lapply(OVEN_kde,
                   FUN = getContour,prob = 0.95)

## ----echo = FALSE--------------------------------------------------------
par(mfrow = c(1,2))
plot(OVEN_kde[[1]],legend = FALSE)
plot(OVEN_95kde[[1]],legend = FALSE)

## ------------------------------------------------------------------------
OVEN_95poly <- lapply(OVEN_95kde, 
                      FUN = function(x){
                        x[x==0]<-NA
                        y <- rasterToPolygons(x, dissolve = TRUE)
                        return(y)
                      })

## ------------------------------------------------------------------------
OVEN_95poly <- mapply(OVEN_95poly, names(OVEN_95poly), 
                  SIMPLIFY = FALSE,
                  FUN = function(x,y){x@polygons[[1]]@ID <- y
                  return(x)})

## ------------------------------------------------------------------------
OVEN_95poly <- do.call(rbind,OVEN_95poly)

## ------------------------------------------------------------------------
OVEN_95poly$Bird <- getSpPPolygonsIDSlots(OVEN_95poly)

## ---- echo = FALSE-------------------------------------------------------
plot(OVEN_95poly, col = cols)

## ------------------------------------------------------------------------
OVEN_95poly

## ------------------------------------------------------------------------
OVENkde_utm <- sp::spTransform(OVEN_95poly, sp::CRS("+init=epsg:32619"))

## ------------------------------------------------------------------------
rgeos::gArea(OVENkde_utm, byid = TRUE)/10000

## ------------------------------------------------------------------------
# read in raster
DEM <- raster::raster("../Spatial_Layers/hb10mdem.txt")

# project raster to match territories
DEMutm <- projectRaster(DEM, crs = "+init=epsg:32619")

## ---- echo = FALSE,warning = FALSE, message = FALSE----------------------
hs <- raster::hillShade(terrain(DEMutm,"slope"),terrain(DEMutm,"aspect"))

par(bty = "n")
plot(hs,col = gray(1:100/100),legend = FALSE, axes = FALSE, ext = extent(OVENkde_utm)+1000)
plot(OVENkde_utm,add = TRUE)

## ------------------------------------------------------------------------
OVENkde_utm$meanElev <- extract(DEMutm,OVENkde_utm, mean)

## ----echo = FALSE--------------------------------------------------------
head(data.frame(BirdID = OVENkde_utm$Bird,
           area_ha = rgeos::gArea(OVENkde_utm, byid = TRUE)/10000,
           Elev_mean = extract(DEMutm,OVENkde_utm, mean),
           Elev_lower = extract(DEMutm,OVENkde_utm,min),
           Elev_upper = extract(DEMutm,OVENkde_utm,max)))

## ------------------------------------------------------------------------
# Empty raster with 1ha resolution
study_plot_raster <- raster::raster(OVENkde_utm, res =c(100,100))

# Covert to SpatialPolygon
study_grid <- as(study_plot_raster,"SpatialPolygons")

## ----echo = FALSE--------------------------------------------------------
plot(study_grid, border = "gray70")
plot(OVENkde_utm,add = TRUE)

## ------------------------------------------------------------------------
# Create a list with all birds wihtin each 1ha grid cell.
birds_in_ha <- sp::over(study_grid, OVENkde_utm, returnList = TRUE)

# Find how many unique birds are in each cell 
study_grid$birds <- unlist(lapply(birds_in_ha,FUN=function(x){length(unique(x$Bird))}))

#convert to raster 
birds.per.ha <- rasterize(study_grid,study_plot_raster,study_grid$birds)

## ---- echo = FALSE-------------------------------------------------------
plot(birds.per.ha)

