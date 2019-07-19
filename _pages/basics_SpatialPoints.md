---
title: "Introduction to spatial points in R"
authors: "Michael T. Hallworth"
contributors: "Clark S. Rushing"
layout: single
classes: wide
permalink: /_pages/basics_SpatialPoints
header:
  caption: 'Photo credit: **M. T. Hallworth**'
  image: assets/images/lookingUp.jpg
sidebar:
  title: "Get Spatial! Using R as GIS"
  nav: "SpatialWorkshop"
---
<a name="TOP"></a>
{% include toc title="In This Activity" %}


This activity will introduce you to working with spatial points in R.

**R Skill Level:** Intermediate - this activity assumes you have a working knowledge of `R`     

<div style="background-color:rgba(0, 0, 0, 0.0470588); border-radius: 25px; text-align:center; vertical-align: middle; padding:3px 0; width: 600px; margin: auto; box-shadow: 4px 5px gray;">

<h1>Objectives & Goals</h1>      
<b>Upon completion of this activity, you will:</b>
<ul>
<li>know how to <strong>create</strong> and write spatial points</li>   
<li>Be able to <strong>project</strong> spatial points</li>             
<li>Be able to <strong>calculate distances</strong> between points</li>             
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

<h4>Installing the packages</h4>     
If installing these packages for the first time consider adding <code>dependencies=TRUE</code><br>   
<li><code>install.packages("raster")</code></li>        
<li><code>install.packages("sp")</code></li>      
<li><code>install.packages("rgeos")</code></li>
</div>
        
<br>

<a href="https://raw.githubusercontent.com/mhallwor/mhallwor.github.io/develop/Rscripts/basics_SpatialPoints.R" target="_blank" class="btn btn--info">Download R script</a> Last modified: 2019-07-19 19:56:35

<hr>

# What are spatial points?    
Spatial points are a set of spatially explicit coordinates that represent a geographic location. Each point represents a location on a surface. Spatial points are created from a series of x and y coordinates. Spatial points can be combined with data frames to create what's called a `SpatialPointsDataFrame`. The difference between `SpatialPoints` and `SpatialPointsDataFrame` are the attributes that are associated with the points. `SpatialPointsDataFrames` have additional information associated with the points (e.g., site, year, individual, etc.) while `SpatialPoints` contain only the spatial information about the point. 

# Creating & writing spatial points   
## Spatial Points in R
Let's begin by creating a set spatial points layer from scratch. We'll use the `sp` package to make a `SpatialPoints` object using randomly generated XY coordinates. Once we create a `SpatialPoints` object in R - we'll take a closer look at its metadata and structure.

load the `sp` package if you haven't already done so. If you need to install the `sp` package - see how to do that [here](#install.packages)

```r
# load library
library(sp)
```

Now that the `sp` library is loaded we can use the `SpatialPoints()` function to create a `SpatialPoints` object in `R`. 

```r
# Generate 100 random X and Y coordinates 
# with longitude and latitude in the familiar
# degrees

x_coords <- runif(n = 100, min = -100, max = -80)
y_coords <- runif(n = 100, min = 25, max = 45)

# Have a look at the first coordinates
head(cbind(x_coords,y_coords))
```

```
##       x_coords y_coords
## [1,] -83.37332 41.31240
## [2,] -86.44798 41.98410
## [3,] -99.72002 39.69552
## [4,] -93.38982 36.30296
## [5,] -97.92359 37.19545
## [6,] -81.41756 31.91193
```

Now that we have generated random coordinates we can make those data spatially explicit. We'll use the `SpatialPoints` function in the `sp` package to do that. Before we use the function let's see what arguments we need to pass to `SpatialPoints`.


```r
args("SpatialPoints")
```

```
## function (coords, proj4string = CRS(as.character(NA)), bbox = NULL) 
## NULL
```

The `SpatialPoints` function is looking for coordinates (`coords`), a projection / datum argument (`proj4string`) and a bounding box (`bbox`). Both `proj4string` and `bbox` have preset values so we don't need to specify them - it'll use the defaults. Let's use those options for now. 

The `coords` input looking for a specific type of input. It needs a matrix or data.frame where the first column is longitude and second is latitude. **Note** - the order is <strong>LONGITUDE</strong> then <strong>LATITUDE</strong>.


```r
# coords = c(longitude,latitude)

firstPoints <- SpatialPoints(coords = cbind(x_coords,y_coords))
```

Let's have a look at what we just created. 

```r
str(firstPoints)
```

```
## Formal class 'SpatialPoints' [package "sp"] with 3 slots
##   ..@ coords     : num [1:100, 1:2] -83.4 -86.4 -99.7 -93.4 -97.9 ...
##   .. ..- attr(*, "dimnames")=List of 2
##   .. .. ..$ : NULL
##   .. .. ..$ : chr [1:2] "x_coords" "y_coords"
##   ..@ bbox       : num [1:2, 1:2] -99.7 25.3 -80.4 44.8
##   .. ..- attr(*, "dimnames")=List of 2
##   .. .. ..$ : chr [1:2] "x_coords" "y_coords"
##   .. .. ..$ : chr [1:2] "min" "max"
##   ..@ proj4string:Formal class 'CRS' [package "sp"] with 1 slot
##   .. .. ..@ projargs: chr NA
```

We can plot the points in space by simply using the `plot` function. 

```r
plot(firstPoints, pch = 19)
```

![plot of chunk plot-points](/figure/pages/basics_SpatialPoints/plot-points-1.png)

<a href="#TOP">Back to top</a>

## Writing a shapefile
We can save our `firstPoints` object as a shapefile using the `raster` package. The `shapefile` function in the `raster` package is very convienent in that it can both read a shapefile into `R` but it can also write a `SpatialPoints` or other spatial object classes (lines, polygons, etc.) to a shapefile. 

```r
library(raster)
shapefile(x = firstPoints, file = "path/to/output/file.shp")
```

<a href="#TOP">Back to top</a>

## Calculate distance between points

One task that may be useful now that we have spatial points is calculating the distance between points either within the same layer or between two layers. Since we already have a SpatialPoints file, we'll calculate the distance between points. We need to be a little careful here. First, we need to make sure we're calculating the distance we intend to calculate. Let's start simple and get Euclidean distances in the units of the SpatialPoints layer. If in meters, it'll return meters. If degrees, it'll return degrees. 

```r
# longlat = FALSE returns Euclidean distance
euclidDist <- sp::spDists(firstPoints,longlat = FALSE)
```

```
##  num [1:100, 1:100] 0 3.15 16.43 11.2 15.12 ...
```

Another option is to calculate the GreatCircle distance. 

```r
# longlat = TRUE returns GreatCircle distance
gcDist <- sp::spDists(firstPoints,longlat = TRUE)
```


```
##  num [1:100, 1:100] 0 267 1395 1032 1334 ...
```

![plot of chunk unnamed-chunk-5](/figure/pages/basics_SpatialPoints/unnamed-chunk-5-1.png)

We'll dive a bit deeper into point-based analyses in <a href="{{ site.baseurl }}/_pages/spatial_predicates" target="_blank">spatial predicates</a> and in the <a href="{{ site.baseurl }}/_pages/activites_GenerateTerritories" target="_blank">activities</a>

