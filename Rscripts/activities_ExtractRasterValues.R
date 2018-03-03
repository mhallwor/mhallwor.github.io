## ----load-packages, warnings = FALSE, error = FALSE, message = FALSE-----
library(raster)
library(rgeos)

## ----read-data-----------------------------------------------------------
points <- sp::SpatialPoints(cbind(runif(100,-100,-90),runif(100,40,45)))
plot(points, pch = 19)

