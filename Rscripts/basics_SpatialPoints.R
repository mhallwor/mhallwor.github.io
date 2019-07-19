## ----echo = FALSE--------------------------------------------------------
knitr::opts_chunk$set(fig.width=10)


## ----load-raster, message = FALSE, error = FALSE, warning = FALSE--------
# load library
library(sp)


## ----spatial-points------------------------------------------------------
# Generate 100 random X and Y coordinates 
# with longitude and latitude in the familiar
# degrees

x_coords <- runif(n = 100, min = -100, max = -80)
y_coords <- runif(n = 100, min = 25, max = 45)

# Have a look at the first coordinates
head(cbind(x_coords,y_coords))


## ----see-args------------------------------------------------------------
args("SpatialPoints")


## ----make-spatial-points-------------------------------------------------
# coords = c(longitude,latitude)

firstPoints <- SpatialPoints(coords = cbind(x_coords,y_coords))


## ----str-points----------------------------------------------------------
str(firstPoints)


## ----plot-points---------------------------------------------------------
plot(firstPoints, pch = 19)


## ----save-shp, eval = FALSE, message = FALSE, warning = FALSE------------
## library(raster)
## shapefile(x = firstPoints, file = "path/to/output/file.shp")


## ------------------------------------------------------------------------
# longlat = FALSE returns Euclidean distance
euclidDist <- sp::spDists(firstPoints,longlat = FALSE)

## ----echo = FALSE--------------------------------------------------------
str(euclidDist)


## ---- warning = FALSE----------------------------------------------------
# longlat = TRUE returns GreatCircle distance
gcDist <- sp::spDists(firstPoints,longlat = TRUE)


## ----echo = FALSE--------------------------------------------------------
str(gcDist)

hist(gcDist[upper.tri(gcDist)],
     col = "gray",border = "white",
     las = 1,
     xlab = "Distance (km)",
     main = "")

