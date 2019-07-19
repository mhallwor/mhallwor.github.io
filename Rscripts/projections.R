## ----echo = FALSE--------------------------------------------------------
options(scipen = 999)
knitr::opts_chunk$set(fig.width=10, fig.align = "center")


## ---- echo = FALSE,message = FALSE, warning = FALSE----------------------
library(raster)
library(sp)

par(mar = c(0,0,2,0),mfrow = c(2,2))
world <- raster::shapefile("../Spatial_Layers/TM_WORLD_BORDERS-0.3.shp")
graticules <- sp::gridlines(world, easts = seq(-180,180,10), norths = seq(-90,90,10))
raster::plot(graticules, col = "gray80",main = "WGS84")
raster::plot(world,col = "gray70",add = TRUE)


worldROB <- sp::spTransform(world,sp::CRS("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))
graticulesROB <- sp::spTransform(graticules,sp::CRS("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))
raster::plot(graticulesROB, col = "gray80", main = "Robinson")
raster::plot(worldROB, add = TRUE, col = "gray70")

worldMOLL <- sp::spTransform(world,sp::CRS("+proj=moll +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))
graticulesMOLL <- sp::spTransform(graticules,sp::CRS("+proj=moll +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))
raster::plot(graticulesMOLL, col = "gray80",main = "Mollewide")
raster::plot(worldMOLL, col = "gray70", add = TRUE)

worldConic <- sp::spTransform(world, sp::CRS("+proj=aea +lat_1=50 +lat_2=90 +lat_0=-90 +lon_0=-10 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"))
graticulesConic <- sp::spTransform(graticules, sp::CRS("+proj=aea +lat_1=50 +lat_2=90 +lat_0=-90 +lon_0=-10 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"))
raster::plot(graticulesConic, col = "gray80",main = "Albers Equal Area")
raster::plot(worldConic, col = "gray70", add = TRUE)


## ----get-polys,eval = FALSE, warning = FALSE,message = FALSE,error = FALSE----
## States <- raster::getData(name = "GADM",
##                              country = "United States",
##                              level = 1,
##                              path = "path/to/save/file",
##                              download = TRUE)
## # Take a look at the shapefile
## States
## 
## # Let's remove Alaska and Hawaii for plotting purposes
## States <- States[States$NAME_1 != "Alaska" & States$NAME_1 != "Hawaii",]


## ----read-states,echo = FALSE,message = FALSE,warning = FALSE------------
library(raster)
library(rgdal)

States <- readRDS("../Spatial_Layers/GADM_2.8_USA_adm1.rds")
States
States <- States[States$NAME_1 != "Alaska" & States$NAME_1 != "Hawaii",]


## ----get-crs-------------------------------------------------------------
# Use the crs() function in raster
raster::crs(States)

# access the projection slot directly
States@proj4string

# access projection as character 
# - this can be very useful when 
#   using the projection of one
#   object to project another
States@proj4string@projargs


## ----project-EqArea------------------------------------------------------
# Define the proj4 string 
EqArea <- "+proj=aea 
           +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 
           +ellps=GRS80 
           +datum=NAD83 
           +units=m +no_defs"

# project using the string
States_EqArea2 <- sp::spTransform(x = States,
                                 CRSobj = CRS(EqArea))

# project using the ESPG authority number
States_EqArea1 <- sp::spTransform(x = States,
                                 CRS("+init=epsg:5070"))


## ---- echo = FALSE-------------------------------------------------------
par(mar = c(0,0,2,0),mfrow = c(1,2))
raster::plot(States_EqArea1, col = "gray70",border = "white",main = "States_EqArea1")
raster::plot(States_EqArea2, col = "gray70",border = "white",main = "States_EqArea2")


## ----remove-crs----------------------------------------------------------
crs(States)<-NA
States


## ------------------------------------------------------------------------
# Let's take a look at the extent of the 
# shapefile to give us a clue to what projection
# it may be. 
States


## ------------------------------------------------------------------------
# Define WGS84 in proj4 string format
WGS84 <- "+proj=longlat +datum=WGS84 
          +no_defs +ellps=WGS84 +towgs84=0,0,0"

# use the crs() function in the raster package
# to define the projection
crs(States) <- WGS84

# take a look
States


## ------------------------------------------------------------------------
# read in raster layer using raster function
# NDVI <- raster("path/to/raster/file")
NDVI <- raster::raster("../Spatial_Layers/MOD_NDVI_M_2018-01-01_rgb_3600x1800.FLOAT.TIFF")


## ----echo = FALSE--------------------------------------------------------
NDVI


## ---- eval = FALSE,warning = FALSE---------------------------------------
## a <- Sys.time()
## NDVIproj <- raster::projectRaster(from = NDVI,
##                           crs = sp::CRS("+init=epsg:5070"))
## Sys.time()-a


## ----echo = FALSE--------------------------------------------------------
NDVIproj <- raster("../Spatial_Layers/MOD_NDVI_M_2018-01-01_rgb_3600x1800.FLOAT_proj.tif")

NDVIproj

NDVIproj[NDVIproj>5]<-NA

par(bty = "n")
plot(NDVIproj,axes = FALSE,legend.args = list("NDVI"))

