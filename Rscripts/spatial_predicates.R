## ---- message = FALSE, error = FALSE, warning = FALSE--------------------
library(raster)
library(sp)
library(rgeos)

## ------------------------------------------------------------------------
# Download or read in states polygon
States <- getData("GADM",country = "United States", level = 1)

## ------------------------------------------------------------------------
# Use the download.file function -
# Don't forget the destfile = "path/where/to/store/file"
download.file(url = "https://www.mbr-pwrc.usgs.gov/bbs/ra15/ra06740.zip",
              destfile = "../Spatial_Layers/ovenbird.zip")

## ------------------------------------------------------------------------
file.exists("../Spatial_Layers/ovenbird.zip")

## ------------------------------------------------------------------------
# unzip the zipped folder
# exdir - where do you want to put the 
#         unzipped files

unzip(zipfile = "../Spatial_Layers/ovenbird.zip",
      exdir = "../Spatial_Layers/ovenbird")

# take a look at the files
list.files("../Spatial_Layers/ovenbird")

## ------------------------------------------------------------------------
OVEN <- raster::shapefile("../Spatial_Layers/ovenbird/ra06740.shp")

# have a look
OVEN

## ------------------------------------------------------------------------
# make a variable used to dissolve boundaries
OVEN$dissolve <- 1

## ------------------------------------------------------------------------
#Dissolve boundaries
OVEN_single_poly <- rgeos::gUnaryUnion(OVEN, 
                                       id = OVEN$dissolve)

# take a look
OVEN_single_poly

## ----echo = FALSE--------------------------------------------------------
raster::plot(OVEN_single_poly, col = "gray88")

## ------------------------------------------------------------------------
# Project states into same CRS
States_aea <- sp::spTransform(States,sp::CRS(OVEN_single_poly@proj4string@projargs))

# Find the intersection using rgeos
a<-Sys.time()
OVENstates_rgeos <- rgeos::gIntersection(spgeom1 = OVEN_single_poly,
                                         spgeom2 = States_aea,
                                         byid = TRUE, 
                                         id = States_aea$NAME_1)
Sys.time()-a

# Find the intersection using raster
a<-Sys.time()
OVENstates_raster <- raster::intersect(x = OVEN_single_poly, 
                                       y = States_aea)
Sys.time()-a

## ----echo = FALSE--------------------------------------------------------
raster::plot(OVENstates_raster)

## ------------------------------------------------------------------------
OVEN_area <- rgeos::gArea(OVEN_single_poly)/10000

## ------------------------------------------------------------------------
# Here we set byid = TRUE 
State_area <- rgeos::gArea(OVENstates_raster, byid = TRUE)/10000

## ------------------------------------------------------------------------
# Get states within their distribution
State_area <- data.frame(State = OVENstates_raster$NAME_1,
                         Area_km = State_area)

head(State_area)

