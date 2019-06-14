## ----echo = FALSE--------------------------------------------------------
knitr::opts_chunk$set(fig.width=10)


## ----load-raster, message = FALSE, error = FALSE, warning = FALSE--------
# load library
library(sp)


## ----spatial-points------------------------------------------------------
# Make a set of coordinates that represent vertices
# with longitude and latitude in the familiar
# degrees

x_coords <- c(-60,-60,-62,-62,-60)
y_coords <- c(20,25,25,20,20)


## ------------------------------------------------------------------------
poly1 <- sp::Polygon(cbind(x_coords,y_coords))


## ------------------------------------------------------------------------
firstPoly <- sp::Polygons(list(poly1), ID = "A")

str(firstPoly,1)


## ------------------------------------------------------------------------
firstSpatialPoly <- sp::SpatialPolygons(list(firstPoly))

firstSpatialPoly


## ------------------------------------------------------------------------
# define the vertices
x1 <- c(-60,-60,-62,-62,-60)
x2 <-c(-50,-50,-55,-55,-50)
y1 <- c(20,25,25,20,20)
y2 <- c(15,25,25,15,15)

# assign the vertices to a `polygon` 
poly1 <- sp::Polygon(cbind(x1,y1))
poly2 <- sp::Polygon(cbind(x2,y2))

# This step combines the last two together - making Polygons and then SpatialPolygons
TwoPolys <- sp::SpatialPolygons(list(sp::Polygons(list(poly1),ID = "A"),
                                     sp::Polygons(list(poly2), ID = "B")))

#Let's take a look
TwoPolys


## ------------------------------------------------------------------------
plot(TwoPolys)


## ----save-shp, eval = FALSE, message = FALSE, warning = FALSE------------
## library(raster)
## shapefile(x = TwoPolys, file = "path/to/output/file.shp")


## ----download-statboundaries, message = FALSE, warning = FALSE-----------
# This looks up the GADM dataset - for the country US and returns 
# the first level of administration which in this case is state boundaries. 

States <- raster::getData("GADM", country = "United States", level = 1)

# Have a look at the data
States


## ------------------------------------------------------------------------
plot(States)


## ------------------------------------------------------------------------
States <- States[States$NAME_1 != "Alaska" & States$NAME_1 != "Hawaii",]

## ----echo = FALSE--------------------------------------------------------
plot(States)


## ------------------------------------------------------------------------
library(rgeos)


## ------------------------------------------------------------------------
USborder <- rgeos::gUnaryUnion(States, id = States$ISO)


## ------------------------------------------------------------------------
# What does it look like
USborder

# Plot it
plot(USborder)


## ------------------------------------------------------------------------
plot(States, 
     col = "gray70", # fill color
     border = "white") # outline color
plot(USborder, 
     lwd = 2,
     add = TRUE) # add to current plot

