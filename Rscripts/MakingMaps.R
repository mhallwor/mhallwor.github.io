## ----setup,echo = FALSE--------------------------------------------------
knitr::opts_chunk$set(error = TRUE)

## ---- warning = FALSE, error = FALSE, message = FALSE--------------------
library(raster)
library(sp)
library(rgeos)
library(leaflet)

## ------------------------------------------------------------------------
# Get State boundaries
States <- raster::getData("GADM", country = "United States", level = 1)

## ---- warning = FALSE, message = FALSE, error = FALSE--------------------
# make NH polygon
NH <- States[States$NAME_1 == "New Hampshire",]

# plot a single polygon
plot(NH)

## ----echo = FALSE, error = FALSE, message = FALSE, warning = FALSE-------
# bring the libraries back
library(dismo)
library(raster)
library(sp)
library(rgeos)

## ------------------------------------------------------------------------
# Set the random seed 
set.seed(12345)

# make random points within New Hampshire
randPts <- sp::spsample(x = NH, n = 100, type = "random")

## ----eval = FALSE--------------------------------------------------------
## # Plot New Hampshire
## plot(NH)

## ----eval = FALSE--------------------------------------------------------
## # Add random points
## plot(randPts,
##      add = TRUE,
##      pch = 19)

## ----echo = FALSE--------------------------------------------------------
# Plot New Hampshire 
plot(NH)
# add random points 
plot(randPts,
     add = TRUE,
     pch = 19)

## ----eval = FALSE--------------------------------------------------------
## # Add States for context
## plot(States,
##      add = TRUE)

## ----echo = FALSE--------------------------------------------------------
# Plot New Hampshire 
plot(NH)
# add random points 
plot(randPts,
     add = TRUE,
     pch = 19)
# Add States for context
plot(States, 
     add = TRUE)

## ------------------------------------------------------------------------
plot(NH)
sp::degAxis(side = 1)
sp::degAxis(side = 2,las = 2)

## ------------------------------------------------------------------------
plot(NH)
# generate the north arrow type 1
arrow1 <-  layout.north.arrow(type = 1) 

# shift the coordinates 
# shift = c(x,y) direction
Narrow1 <- maptools::elide(arrow1, shift = c(extent(NH)[2],extent(NH)[3]))

# add north arrow to current NH plot
plot(Narrow1, add = TRUE,col = "black")

# Make north arrow type 2
arrow2 <- layout.north.arrow(type = 2)

# shift the coordinates
# shift = c(x,y) direction
Narrow2 <- maptools::elide(arrow2, shift = c(extent(NH)[1]-0.5,extent(NH)[3]))

# add north arrow to current plot
plot(Narrow2, add = TRUE, col = "blue")

## ------------------------------------------------------------------------
# New Hampshire plot
plot(NH)
# scale bar layer
sb <- layout.scale.bar(height = 0.05)
# shift scale bar
sb_slide <- maptools::elide(sb, shift = c(extent(NH)[1],extent(NH)[3]-0.1))
# Add to plot
plot(sb_slide, add = TRUE, col = c("white","black"))

## ------------------------------------------------------------------------
plot(NH)
#d = distance in km
#xy = location where to place scalebar
#type = "bar" or "line"
#divs = how many divisions in bar/line
#below = text below bar
#lonlat =  projection in longitude / latitude?
#label = labels for c(beginning, middle, end)
#adj = label adjustments c(horiz,vertical)
#lwd = width of line

raster::scalebar(d = 100, # distance in km
                 xy = c(extent(NH)[1]+0.01,extent(NH)[3]+0.15),
                 type = "bar", 
                 divs = 2, 
                 below = "km", 
                 lonlat = TRUE,
                 label = c(0,50,100), 
                 adj=c(0, -0.75), 
                 lwd = 2)

## ---- eval = FALSE-------------------------------------------------------
## # Download a map from Google Maps API
## # exp = multiplier to change extent
## #       values less than 1 - zooms in
## #       values greater than 1 - zooms out
## # zoom = another parameter to
## #       zoom in or out on areas
## #     1 = global, 20 = pick out individual trees
## # type = Type of image to return
## # lonlat = return in crs lonlat?
## # rgb - return raster stack with rgb values?
## 
## # Avoid weird white space by using using the rgb = TRUE &
## # using raster's plotRGB function.
## 
## sat <- gmap(x = NH,
##             exp = 1,
##             zoom = NULL,
##             type = "satellite",
##             lonlat = FALSE,
##             rgb = TRUE)
## 
## # plotRGB uses the raster stack to make the colors
## raster::plotRGB(sat)

## ----echo = FALSE--------------------------------------------------------
# Download a map from Google Maps API
      # multiplier to change extent
      # values less than 1 - zooms in
      # values greater than 1 - zooms out
      # zoom is another parameter to
      # zoom in or out on areas
      # 1 = world, 20 = pick out individual trees
      # Type of image to return 
      # return in coord lonlat
      # return raster stack with red,green,blue values

sat <- gmap(x = NH,
            exp = 1,
            zoom = NULL,
            type = "satellite",
            lonlat = FALSE,
            rgb = TRUE)

# Project NH into merc projection
NHproj <- sp::spTransform(NH,sp::CRS(sat@crs@projargs))

# Avoid weird white space by using using the rgb = TRUE &
# using raster's plotRGB function.
par(mfrow = c(1,2))
plotRGB(sat)
# mask sat by NH
sat_mask <- raster::mask(sat,NHproj)
plotRGB(sat_mask)
# add states but transform first
plot(sp::spTransform(States,sp::CRS(sat@crs@projargs)),add = TRUE)

## ------------------------------------------------------------------------
elev <- raster::raster("../Spatial_Layers/hb10mdem.txt")

## ------------------------------------------------------------------------
plot(elev)

## ---- fig.width = 10-----------------------------------------------------
# Plot two plots c(rows,columns)
par(mfrow = c(1,2))
# plot elevation with blue.purple.yellow pallette
plot(elev,
     col = sp::bpy.colors())
# plot elevation with yellow.purple.blue pallette
plot(elev,
     col = rev(sp::bpy.colors()))

## ---- warning = FALSE----------------------------------------------------
# plot histogram
hist(elev)

# get the minimum value
cellStats(elev,min)
# get the maximum value
cellStats(elev,max)

# find quantiles of the elevation 
quantile(elev, probs = c(0.25,0.5,0.75))

## ------------------------------------------------------------------------
set.breaks <- quantile(elev, probs = c(0,0.25,0.5,0.75,1))
plot(elev,
     breaks = set.breaks,
     col = c("blue","yellow","green","red"))

## ------------------------------------------------------------------------
# Generate color ramp from "gray88" to "black"
newcolors <- colorRampPalette(colors = c("gray88","black"))

# Use the set.breaks and colors
plot(elev,
     breaks = set.breaks,
     col = newcolors(5))

# Use 200 colors in the color ramp palette
plot(elev,
     col = newcolors(200))

## ------------------------------------------------------------------------
# generate aspect and slope
aspect <- raster::terrain(elev,"Aspect")
slope <- raster::terrain(elev,"Slope")

# combine aspect and ratio to generate hillshade
HS <- raster::hillShade(aspect,slope)

plot(HS)

## ------------------------------------------------------------------------
# add color over the hillshade
plot(HS, 
     col = gray(1:100/100),
     legend = FALSE) # don't plot legend
plot(elev, 
     col = bpy.colors(200), 
     add = TRUE, #add to current plot
     alpha = 0.5) # set transparency

## ------------------------------------------------------------------------
# no margins, no border #
par(mar = c(4,0,0,0),bty = "n")
# suppress axes
plot(HS, 
     col = gray(1:100/100), 
     legend = FALSE,
     axes = FALSE)
plot(elev,
     col = bpy.colors(200),
     horizontal = TRUE,
     alpha = 0.5,
     add = TRUE)

## ------------------------------------------------------------------------
# smallplot
  # where to plot the legend
  # values between 0-1 (percent of plot)
  # c(x1,x2,y1,y2)
# axis.args
par(bty = "n")
plot(elev,
     col = bpy.colors(200),
     legend = FALSE,
     axes = FALSE)
plot(elev,
     legend.only = TRUE,
     horizontal = TRUE,
     col= bpy.colors(200),
     add = TRUE,
     smallplot = c(0.1,0.4,0.1,0.12),
     legend.width = 0.25,
     legend.shrink = 0.5,
     axis.args = list(at = seq(200,1000,100),
                      las = 2,
                      labels = seq(200,1000,100),
                      cex.axis = 1,
                      mgp = c(5,0.3,0)),
     legend.args = list(text = "Elevation", 
                      side = 3, 
                      font = 2, 
                      line = 0.5, 
                      cex = 1))

## ------------------------------------------------------------------------
# Read the State boundaries
States <- raster::getData("GADM",country = "United States", level = 1)

# Subset to include only New Hampshire
NH <- States[States$NAME_1 == "New Hampshire",]

# This call makes the map
  # inital map
mapNH <- leaflet(data = NH) %>%  
  # add a baselayer
      addTiles() %>% 
  # specific baselayer with name          
   addProviderTiles("Esri.WorldImagery", group = "Aerial") %>% 
  # specific baselayer with name
   addProviderTiles("OpenTopoMap", group = "Topography")%>% 
  # add New Hampshire polygon
   addPolygons(., stroke = TRUE, weight = 1, color = "black", 
  # highlight when over
      highlightOptions = highlightOptions(color = "white", weight = 2, 
      bringToFront = TRUE)) %>%
 # Layers control 
  # give user control of basemap 
            addLayersControl(      
      # these groups are labelled above
              baseGroups = c("Aerial", "Topography"), 
        # collapse options
              options = layersControlOptions(collapsed = TRUE)) 
# add map inset to plot
mapNH %>% addMiniMap() 

