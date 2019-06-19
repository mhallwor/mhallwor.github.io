## ----echo = FALSE--------------------------------------------------------
knitr::opts_chunk$set(fig.width=10)


## ----warning = FALSE, error = FALSE, message = FALSE---------------------
library(raster)
library(sp)
library(rgeos)


## ------------------------------------------------------------------------
# Read in Administrative forest boundaries 
# This shapefile has boundary information
# for forests the U.S. federal govt is
# responsible for - i.e., National Forests,
# National Monuments, etc. 

NatForest <- raster::shapefile("../Spatial_Layers/S_USA.AdministrativeForest.shp")

# Take a glance at the file
NatForest


## ------------------------------------------------------------------------
CNF <- NatForest[grep(x=NatForest$FORESTNAME,pattern="Coronado"),]


## ----get-elev------------------------------------------------------------
# Get elevation data using the raster package
DEM <- raster::getData(name = "alt", country = "United States")

# Save only the elevation in the lower 48
DEM <- DEM[[1]]


## ----plot-CNF, echo = FALSE----------------------------------------------
par(bty = "n")
plot(DEM,ext = extent(CNF),axes = FALSE)
plot(CNF, add = TRUE)


## ----make-random---------------------------------------------------------
set.seed(12345)

surveyPts <- sp::spsample(x = CNF, n = 100, type = "regular")


## ------------------------------------------------------------------------
plot(CNF)
plot(surveyPts, add = TRUE, pch = 19)


## ------------------------------------------------------------------------
surveyPts


## ------------------------------------------------------------------------
# Define the projection in proj4 format
EqArea <- "+proj=aea 
           +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 
           +ellps=GRS80 
           +datum=NAD83 
           +units=m +no_defs"

# project data using the sp package
surveyPts_m <- sp::spTransform(surveyPts, sp::CRS(EqArea))

# project forest boundary
CNF_m <- sp::spTransform(CNF, sp::CRS(EqArea))


## ------------------------------------------------------------------------
DEM <- crop(DEM,CNF)

# take a look
DEM


## ------------------------------------------------------------------------
DEM_m <- projectRaster(DEM, crs = EqArea)


## ------------------------------------------------------------------------
library(rgeos)
surveyCircle <- gBuffer(surveyPts_m, width = 50, byid = TRUE)


## ------------------------------------------------------------------------
pt_elev <- extract(DEM_m, surveyCircle, fun = mean, na.rm = TRUE)


## ----echo = FALSE--------------------------------------------------------
par(bty = "l")
hist(pt_elev, xlab = "Elevation", ylab = "Frequency", main = "",
     col = "gray", border = "gray88", yaxt = "n")
axis(2,las = 2)


## ---- message = FALSE, error = FALSE, warning = FALSE--------------------
#library(AHMbook)
#library(unmarked)

# Simulate occupancy data
# M = number of sites 
# J = number of occassions

simCount <- AHMbook::simOcc(M = length(surveyPts), 
                            J = 3, 
                            mean.occupancy = 0.6, 
                            mean.detection = 0.7,
                            show.plot = FALSE)$y

# see first few rows
head(simCount)


## ------------------------------------------------------------------------
# Make unmarked frame for occupancy data
umf <- unmarked::unmarkedFrameOccu(y = simCount, 
                                   siteCovs=data.frame(pt_elev), 
                                   obsCovs=NULL)

# run the occupancy model
occ <- unmarked::occu(~1~pt_elev,umf)


## ------------------------------------------------------------------------
occMap <- exp(unmarked::coef(occ)[1]+unmarked::coef(occ)[2]*DEM_m)/
          (1+exp(unmarked::coef(occ)[1]+unmarked::coef(occ)[2]*DEM_m))

plot(mask(occMap, CNF_m),col = bpy.colors(30))

