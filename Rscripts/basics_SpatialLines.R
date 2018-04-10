## ------------------------------------------------------------------------
# generate 100 random XY coords 
x_coords <- runif(n = 100, min = -100, max = -80)
y_coords <- runif(n = 100, min = 25, max = 45)

# make a unique identifier for each line
ID <- paste0("line_",1:100)

## ----echo = FALSE--------------------------------------------------------
# Print the first few lines just to see what it looks like
head(data.frame(x_coords = x_coords,y_coords = y_coords, ID = ID))

## ------------------------------------------------------------------------
line_obj <- sp::Line(cbind(x_coords[1:2],y_coords[1:2]))

lines_obj <- sp::Lines(list(line_obj),ID=ID[1])

Line1 <- sp::SpatialLines(list(lines_obj))

## ------------------------------------------------------------------------
# make SpatialPoints
points <- sp::SpatialPoints(cbind(x_coords,y_coords))

# use as to convert to line
sp_line <- as(points,"SpatialLines")

## ----echo = FALSE--------------------------------------------------------
sp_line
sp::plot(sp_line)

## ----echo = FALSE--------------------------------------------------------
# simply subset out the points you want
first10 <- as(points[1:10],"SpatialLines")
last20 <- as(points[(length(points)-20):length(points)],"SpatialLines")

#plot them
raster::plot(last20)
raster::plot(first10,add = TRUE, lwd = 3)

## ------------------------------------------------------------------------
# returns length in coordinate reference system units
# here it's degrees - it assumes planar coordinates
rgeos::gLength(sp_line)

## ------------------------------------------------------------------------
# great circle distance along our line
geosphere::lengthLine(sp_line)

