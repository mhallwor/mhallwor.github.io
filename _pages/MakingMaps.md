---
title: "Making maps in R"
classes: wide
contributors: Clark S. Rushing
header:
  caption: 'Photo credit: **M. T. Hallworth**'
  image: assets/images/lookingUp.jpg
layout: single
permalink: /_pages/MakingMaps
sidebar:
  nav: SpatialWorkshop
  title: Get Spatial! Using R as GIS
authors: Michael T. Hallworth
---
<a name="TOP"></a>
{% include toc title="In This Activity" %}


This activity will introduce you to creating maps and plotting spatial data in R.

**R Skill Level:** Intermediate - this activity assumes you have a working knowledge of `R`     

<div style="background-color:rgba(0, 0, 0, 0.0470588); border-radius: 25px; text-align:center; vertical-align: middle; padding:3px 0; width: 600px; margin: auto; box-shadow: 4px 5px gray;">

<h1>Objectives & Goals</h1>      
<b>Upon completion of this activity, you will:</b>
<ul>
<li>know how to <strong>plot</strong> spatial</li>
<li>Be able to <strong>add a scalebar</strong> to a plot</li>  
<li>Be able to <strong>customize legends</strong> for raster data</li>             
<li>Be able to generate an <strong>interactive plot</strong> using leaflet</li> 
</ul>
</div>

<br>
<br>
<a name="install.packages"></a>
<div style="background-color:rgba(0, 1, 1, 0.0470588); border-radius: 25px; text-align:center; vertical-align: middle; padding:2px 0; width: 600px; margin: auto; box-shadow: 4px 5px gray;">
<h3> Required packages</h3> 
To complete the following activity you will need the following packages installed:

<strong>raster</strong>               
<strong>sp</strong>     
<strong>rgeos</strong>      
<strong>leaflet</strong>     
<strong>dismo</strong>      
  
<h4>Installing the packages</h4>     
If installing these packages for the first time consider adding <code>dependencies=TRUE</code><br>   
<li><code>install.packages("raster",dependencies = TRUE)</code></li>
<li><code>install.packages("rgdal",dependencies = TRUE)</code></li>
<li><code>install.packages("rgeos",dependencies = TRUE)</code></li>
<li><code>install.packages("sp",dependencies = TRUE)</code></li>
<li><code>install.packages("mapview",dependencies = TRUE)</code></li>     
<li><code>install.packages("leaflet",dependencies = TRUE)</code></li>
<li><code>devtools::install_github("rspatial/dismo")</code></li>

</div>
        
<br>

<a href="https://raw.githubusercontent.com/mhallwor/mhallwor.github.io/develop/Rscripts/MakingMaps.R" target="_blank" class="btn btn--info">Download R script</a> Last modified: 2019-09-19 01:26:40

<hr>


```r
library(raster)
library(sp)
library(rgeos)
library(leaflet)
library(mapview)
```

## Visualization 

Before we get into making static maps we'll cover a basic interactive map. Lots of people rely on ArcMap to view their data or for the ability to scroll through spatial data. The <code>mapview</code> package provides users with a basic, interactive map with several different baselayers with a single line of code. If you're working in RStudio the map will open in the Viewer tab. If working in the console then the map will open in a web browser.


```r
# Coordinates of a mystery location #
MysteryLocation <- cbind(71.73,43.94)

# Create a SpatialPoints layer with known crs 
MysteryLoc <- SpatialPoints(MysteryLocation,proj4=CRS("+init=epsg:4326"))

# create an interactive map to reveal the mystery location 
mapview(MysteryLoc)
```

![plot of chunk unnamed-chunk-2](/figure/pages/MakingMaps/unnamed-chunk-2-1.png)


## Making Maps

Making maps is as much an art as it is a science and making nice maps takes a lot of practice. We won't go into map making in great detail here. I'll illustrate some features that you can use to maps in R. We'll start with basic maps of spatial features like points and work our way up to plotting rasters with custom legends and finally to interactive plots. 

Let's read in the states <code>SpatialPolygonsDataFrame</code> using the <code>raster</code> package to get started. 

```r
# Get State boundaries
States <- raster::getData("GADM", country = "United States", level = 1)
```

Now let's plot New Hampshire 

```r
# make NH polygon
NH <- States[States$NAME_1 == "New Hampshire",]

# plot a single polygon
plot(NH)
```

![plot of chunk unnamed-chunk-4](/figure/pages/MakingMaps/unnamed-chunk-4-1.png)

All we did was call the `plot()` function on our spatial polygon and it created a map. Pretty straight forward so far. 

If you get the following error be sure to load the `raster` package before plotting. You get the following error because the basic plot function in `R` doesn't know how to plot spatial data without `raster` or some other spatial package loaded. 

>Error in as.double(y) : cannot coerce type 'S4' to vector of type 'double'<



<a href="#TOP">back to top</a>

## Adding multiple spatial layers
Maps are often a few different spatial layers added together. Therefore, we need to know how to plot multiple spatial layers together to render maps. These next few lines of code will add a few different data layers together to make a map. First, we'll generate some random points within New Hampshire and plot those. Then, we'll put New Hampshire into context so it doesn't look like its floating. Then we'll add some color to add emphasis. 

First the random points. 

```r
# Set the random seed 
set.seed(12345)

# make random points within New Hampshire
randPts <- sp::spsample(x = NH, n = 100, type = "random")
```

Plot New Hampshire boundary

```r
# Plot New Hampshire
plot(NH)
```

Add the random points on top of New Hampshire

```r
# Add random points
plot(randPts, 
     add = TRUE,
     pch = 19)
```

![plot of chunk unnamed-chunk-9](/figure/pages/MakingMaps/unnamed-chunk-9-1.png)
    
add the other state boundaries for context

```r
# Add States for context
plot(States, 
     add = TRUE)
```

![plot of chunk unnamed-chunk-11](/figure/pages/MakingMaps/unnamed-chunk-11-1.png)

<a href="#TOP">back to top</a>

## Adding map extras
#### axes 
Let's add some location information like latitude and longitude for reference. The <code>sp</code> function has a nice axis helper to do just that and make it look 'pretty'. 


```r
plot(NH)
sp::degAxis(side = 1)
sp::degAxis(side = 2,las = 2)
```

![plot of chunk unnamed-chunk-12](/figure/pages/MakingMaps/unnamed-chunk-12-1.png)

#### north arrow
The <code>sp</code> package also has a nice feature that generates a north arrow. We'll put types on the same map. The <code>layout.north.arrow</code> function creates a spatial object that has spatial coordinates that are correct relative to themselves. Therefore, in order to place the north arrow on the map in locations that we want we can shift the spatial coordinates of the north arrow using the <code>elide</code> function in the <code>maptools</code> package. 

There are two types of north arrow included in the <code>layout.north.arrow</code> function. The first type (<code>type = 1</code>) places a north arrow behind a capital N. The second type (<code>type = 2</code>) is a northward facing arrow. 


```r
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
```

![plot of chunk unnamed-chunk-13](/figure/pages/MakingMaps/unnamed-chunk-13-1.png)

#### scalebar

Both <code>raster</code> package and the <code>sp</code> packages have a function to add a scale bar. The scalebar in the <code>sp</code> package is very basic. 


```r
# New Hampshire plot
plot(NH)
# scale bar layer
sb <- layout.scale.bar(height = 0.05)
# shift scale bar
sb_slide <- maptools::elide(sb, shift = c(extent(NH)[1],extent(NH)[3]-0.1))
# Add to plot
plot(sb_slide, add = TRUE, col = c("white","black"))
```

![plot of chunk unnamed-chunk-14](/figure/pages/MakingMaps/unnamed-chunk-14-1.png)

Now the scalebar in the <code>raster</code> package.

```r
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
```

![plot of chunk unnamed-chunk-15](/figure/pages/MakingMaps/unnamed-chunk-15-1.png)

<a href="#TOP">back to top</a>

## Adding Satellite Image

Adding satellite images from Google Earth is also possible. We'll use the <code>dismo</code> package for that. The <code>gmap()</code> function returns a google map. Several types ("roadmap", "satellite", "hybrid", "terrain") are available. You can use the <code>style</code> option to customize colors, etc. See <a href="https://developers.google.com/maps/documentation/static-maps/styling" target="_blank">here</a> for style options.

<b>Note</b>: To use Google maps you need to <a href="https://developers.google.com/maps/documentation/embed/get-api-key" target="_blank">get an API key</a>. 


```r
# Download a map from Google Maps API
# exp = multiplier to change extent
#       values less than 1 - zooms in
#       values greater than 1 - zooms out
# zoom = another parameter to
#       zoom in or out on areas
#     1 = global, 20 = pick out individual trees
# type = Type of image to return 
# lonlat = return in crs lonlat?
# rgb - return raster stack with rgb values?

# Avoid weird white space by using using the rgb = TRUE &
# using raster's plotRGB function.

sat <- gmap(x = NH,
            exp = 1,
            map_key = "add your key here",
            zoom = NULL,
            type = "satellite",
            lonlat = FALSE,
            rgb = TRUE)

# plotRGB uses the raster stack to make the colors
raster::plotRGB(sat)
```



<img src = "https://raw.githubusercontent.com/mhallwor/mhallwor.github.io/master/assets/images/gmapNH.png">

<a href="#TOP">back to top</a>

## Plotting rasters 

In this next section we'll go through a few of the basics for plotting rasters. We'll use an elevation raster of Hubbard Brook Experimental Forest in New Hampshire for the next few examples. 


```r
elev <- raster::raster("../Spatial_Layers/hb10mdem.txt")
```

Let's take a quite look at what the elevation looks like. 

```r
plot(elev)
```

![plot of chunk unnamed-chunk-19](/figure/pages/MakingMaps/unnamed-chunk-19-1.png)

Let's playing with the colors and assign colors to specific elevation bands. First, we'll change the colors away from the default. You can change the colors using <code>col</code> option. 


```r
# Plot two plots c(rows,columns)
par(mfrow = c(1,2))
# plot elevation with blue.purple.yellow pallette
plot(elev,
     col = sp::bpy.colors())
# plot elevation with yellow.purple.blue pallette
plot(elev,
     col = rev(sp::bpy.colors()))
```

![plot of chunk unnamed-chunk-20](/figure/pages/MakingMaps/unnamed-chunk-20-1.png)

One way set different colors based on raster values you can use the <code> breaks</code> option. The <code>breaks</code> option sets the breaks for changes in colors. Before we set the breaks, let's have a look at the values. 


```r
# plot histogram
hist(elev)
```

![plot of chunk unnamed-chunk-21](/figure/pages/MakingMaps/unnamed-chunk-21-1.png)

```r
# get the minimum value
cellStats(elev,min)
```

```
## [1] 168
```

```r
# get the maximum value
cellStats(elev,max)
```

```
## [1] 1004
```

```r
# find quantiles of the elevation 
quantile(elev, probs = c(0.25,0.5,0.75))
```

```
## 25% 50% 75% 
## 337 536 654
```

We'll illustrate how to use the <code>breaks</code> option by setting different colors for the quantiles. The below example is to show how to change the colors. 

```r
set.breaks <- quantile(elev, probs = c(0,0.25,0.5,0.75,1))
plot(elev,
     breaks = set.breaks,
     col = c("blue","yellow","green","red"))
```

![plot of chunk unnamed-chunk-22](/figure/pages/MakingMaps/unnamed-chunk-22-1.png)

Because elevation is a continuous variable we should use some sort of color-ramp instead of discrete colors. You can use the <code>colorRampPalette</code> function to generate values. 

```r
# Generate color ramp from "gray88" to "black"
newcolors <- colorRampPalette(colors = c("gray88","black"))

# Use the set.breaks and colors
plot(elev,
     breaks = set.breaks,
     col = newcolors(5))
```

![plot of chunk unnamed-chunk-23](/figure/pages/MakingMaps/unnamed-chunk-23-1.png)

```r
# Use 200 colors in the color ramp palette
plot(elev,
     col = newcolors(200))
```

![plot of chunk unnamed-chunk-23](/figure/pages/MakingMaps/unnamed-chunk-23-2.png)

Here's a little trick to make elevation maps look better. Let's add some 'topography' by using the `hillShade` function. We can generate a hillshade layer by combining slope and aspect. The terrain function generates slope and aspect from the digital elevation model.  


```r
# generate aspect and slope
aspect <- raster::terrain(elev,"Aspect")
slope <- raster::terrain(elev,"Slope")

# combine aspect and ratio to generate hillshade
HS <- raster::hillShade(aspect,slope)

plot(HS)
```

![plot of chunk unnamed-chunk-24](/figure/pages/MakingMaps/unnamed-chunk-24-1.png)

Now that we've generated some 'texture' we can add colors on top. The <code>alpha</code> option sets transparency. In order to add colors we need to plot two rasters on the same plot. When doing that the legends plot on top of one another. Let's suppress the legend on the hillshade layer. 


```r
# add color over the hillshade
par(bty = "l") # only have x - y axis
plot(HS, 
     col = gray(1:100/100),
     legend = FALSE, # don't plot legend
     las = 1) # axis labels are parallel with plot
plot(elev, 
     col = bpy.colors(200), 
     add = TRUE, #add to current plot
     alpha = 0.5) # set transparency
```

![plot of chunk unnamed-chunk-25](/figure/pages/MakingMaps/unnamed-chunk-25-1.png)

<a href="#TOP">back to top</a>

#### legends 
Legend placement, orientation and size can all be altered to make the legend fit a map. Below we'll go over a few options we can change to make legends look better.

horizontal legend

```r
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
```

![plot of chunk unnamed-chunk-26](/figure/pages/MakingMaps/unnamed-chunk-26-1.png)

custom labels and placement
We can use the smallplot option or move the legend around and the axis.args to change labels and label placement. Legend.args sets the large label "Elevation" in this case.

```r
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
     legend.args = list(text = "Elevation (m)", 
                      side = 3, 
                      font = 2, 
                      line = 0.5, 
                      cex = 1))
```

![plot of chunk unnamed-chunk-27](/figure/pages/MakingMaps/unnamed-chunk-27-1.png)

<a href="#TOP">back to top</a>

## Interactive plots 

The `leaflet` package makes making interactive plots fairly straightforward once you learn the syntax. See <a href = "https://rstudio.github.io/leaflet/" target="_blank">here</a> for lots more info on leaflet functions. The general workflow for interactive plots is:

<li> generate the interactive plot by calling `leaflet(data = spatial data)`</li>
<li> add base layers using the `addTiles` function. </li>
<li> add additional layers using addPolygons, addMarkers, addCircleMarkers, etc. </li>

The following code creates a rather simple map with a small inset, two base layers the user can switch between and the polygon boundary is highlighted when the users mouse navigates over it.  

```r
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
```

![plot of chunk unnamed-chunk-28](/figure/pages/MakingMaps/unnamed-chunk-28-1.png)

<a href="#TOP">back to top</a>
