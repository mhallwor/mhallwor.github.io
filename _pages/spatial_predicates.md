---
title: "Spatial Predicates"
authors: "Michael T. Hallworth"
contributors: "Clark S. Rushing"
layout: single
classes: wide
permalink: /_pages/spatial_predicates
header:
  caption: 'Photo credit: **M. T. Hallworth**'
  image: assets/images/lookingUp.jpg
sidebar:
  title: "Get Spatial! Using R as GIS"
  nav: "SpatialWorkshop"
last_modified_at: "2018-04-03T23:44:02-4:00"
---
<a name="TOP"></a>

{% include toc title="In This Activity" %}

**R Skill Level:** Intermediate - this activity assumes you have a working knowledge of `R` 


<div style="background-color:rgba(0, 0, 0, 0.0470588); border-radius: 25px; text-align:center; vertical-align: middle; padding:3px 0; width: 600px; margin: auto; box-shadow: 4px 5px gray;">

<h1>Objectives & Goals</h1>      
<b>Upon completion of this activity, you will:</b>
<ul>
<li> know to <strong>clip</strong> features </li>
<li> know how to find where features <strong>intersect</strong> </li>
<li> know how to <strong>dissolve</strong> features </li>
<li> be able to determine if features are <strong>within / contain</strong> other features</li>
<li> be able to calculate the <strong> area </strong> of a feature</li>
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
If installing these packages for the first time consider adding <code>dependencies=TRUE</code>        

<li><code>install.packages("raster",dependencies = TRUE)</code></li>
<li><code>install.packages("rgdal",dependencies = TRUE)</code></li>
<li><code>install.packages("rgeos",dependencies = TRUE)</code></li>
<li><code>install.packages("sp",dependencies = TRUE)</code></li>
<br> 
</div>
        
<br>

<a href="https://raw.githubusercontent.com/mhallwor/mhallwor.github.io/develop/Rscripts/spatial_predicates.R" target="_blank" class="btn btn--info">Download R script</a> Last modified: 2019-07-19 19:56:35

<hr> 

# Spatial predicates
<a href="https://en.wikipedia.org/wiki/DE-9IM#Spatial_predicates" target="_blank">Spatial predicates</a> are a series of spatial relations between two or more spatial features. The table below gives simple definitions for the predicate and the accompanying function in the <code>rgeos</code> package. The <code>sf</code> package also has similar functions.    
<br>
    
|Predicate|Definition|Function|    
|:-------|--------|:-------|
|Equals|Geometries are equivilant|<code>gEquals()</code>|
|Disjoint|No commonality in geometries|<code>gIntersects()</code>|
|Touches|Geometries have one common boundary point|<code>gTouches()</code>|
|Contains|Geometry is contained by or contains another geometry|<code>gContains()</code>|
|Covers|Geometry <code>a</code> is covered by <code>b</code>|<code>gCovers()</code>|

These functions can be very helpful and are commonly performed functions in GIS. 

Before we get started we'll load the libraries that we need for this activity. 

```r
library(raster)
library(sp)
library(rgeos)
```

<a href="#TOP">back to top</a>

### Clipping a polygon

Clipping one polygon by another is a fairly common GIS procedure that you may have done in the past. To demonstrate how we can do this in <code>R</code> we'll use a species distribution map to clip the United States to determine which states the species distribution includes. We'll learn some new techniques along the way. For instance we'll encounter the function used to <strong> dissolve </strong> boundaries. We'll <strong>clip</strong> a polygon and then find the <strong>area</strong> of the overlapping polygons. 

First, we need to get a polygon file of the United States.

```r
# Download or read in states polygon
States <- getData("GADM",country = "United States", level = 1)
```

Next, let's grab a polygon shapefile of the Ovenbird distribution from the <a href="https://www.mbr-pwrc.usgs.gov/bbs/shape_ra15.html" target="_blank">Breeding Bird Survey's</a> website.

```r
# Use the download.file function -
# Don't forget the destfile = "path/where/to/store/file"
download.file(url = "https://www.mbr-pwrc.usgs.gov/bbs/ra15/ra06740.zip",
              destfile = "../Spatial_Layers/ovenbird.zip")
```

The file should have downloaded. Let's check to see that the file downloaded properly.

```r
file.exists("../Spatial_Layers/ovenbird.zip")
```

```
## [1] TRUE
```
Now let's unzip the file and see what's in it. 

```r
# unzip the zipped folder
# exdir - where do you want to put the 
#         unzipped files

unzip(zipfile = "../Spatial_Layers/ovenbird.zip",
      exdir = "../Spatial_Layers/ovenbird")

# take a look at the files
list.files("../Spatial_Layers/ovenbird")
```

```
## [1] "ra06740.dbf" "ra06740.prj" "ra06740.shp" "ra06740.shx"
```

Let's read in the Ovenbird's distribution

```r
OVEN <- raster::shapefile("../Spatial_Layers/ovenbird/ra06740.shp")

# have a look
OVEN
```

```
## class       : SpatialPolygonsDataFrame 
## features    : 10890 
## extent      : -1900596, 3106908, 1075820, 4325680  (xmin, xmax, ymin, ymax)
## crs         : +proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0 
## variables   : 6
## names       :       AREA, PERIMETER, TMPCOV_, TMPCOV_ID, GRID_CODE,   RASTAT 
## min values  :   433703.6,  3037.274,      10,         0,         0,        0 
## max values  : 1389074000,  172282.4,    9999,      9999,     38112, 70.57192
```

<a href="#TOP">back to top</a>

### Dissolving features 
One thing you should notice is that there are a ton of polygons. There are 10890 different polygons! Let's dissolve the boundaries so we have only a single polygon. In order to do that we need to make sure we have a variable within <code>OVEN</code> that is shared by all features. Looks like we'll need to create one. 

```r
# make a variable used to dissolve boundaries
OVEN$dissolve <- 1
```

Now that we have that field we can use the `gUnaryUnion` function to make a single polygon. 

```r
#Dissolve boundaries
OVEN_single_poly <- rgeos::gUnaryUnion(OVEN, 
                                       id = OVEN$dissolve)

# take a look
OVEN_single_poly
```

```
## class       : SpatialPolygons 
## features    : 1 
## extent      : -1900596, 3106908, 1075820, 4325680  (xmin, xmax, ymin, ymax)
## crs         : +proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0
```
![plot of chunk unnamed-chunk-10](/figure/pages/spatial_predicates/unnamed-chunk-10-1.png)

Here we'll use the <code>gIntersection</code> function in the <code>rgeos</code> package. The <code>rgeos</code> package can recognize that the <code>coordinate reference systems</code> differ between our two polygon files. It should give you a warning and proceed. Make sure to include <code>byid = TRUE</code> otherwise you only get a single polygon return - and it takes 15 times longer! 

The <code>intersect</code> function in the raster package is a little slower than the <code>gIntersection</code> function in the rgeos package. The one huge advantage to using raster's <code>intersect</code> is that it preserves associated data in a SpatialPolygonsDataFrame. 


```r
# Project states into same CRS
States_aea <- sp::spTransform(States,sp::CRS(OVEN_single_poly@proj4string@projargs))

# Find the intersection using rgeos
a<-Sys.time()
OVENstates_rgeos <- rgeos::gIntersection(spgeom1 = OVEN_single_poly,
                                         spgeom2 = States_aea,
                                         byid = TRUE, 
                                         id = States_aea$NAME_1)
Sys.time()-a
```

```
## Time difference of 6.290228 secs
```

```r
# Find the intersection using raster
a<-Sys.time()
OVENstates_raster <- raster::intersect(x = OVEN_single_poly, 
                                       y = States_aea)
Sys.time()-a
```

```
## Time difference of 7.862392 secs
```

![plot of chunk unnamed-chunk-12](/figure/pages/spatial_predicates/unnamed-chunk-12-1.png)

Now that we have a clipped polygon, let's determine the area of each state that the Ovenbird distribution overlaps. To do this we'll use the <code>gArea</code> function in the rgeos package. First, let's see how much area the Ovenbird's distribution encompasses.


```r
OVEN_area <- rgeos::gArea(OVEN_single_poly)/10000
```

Find area of each state. Here we set <code>byid = TRUE</code> to get the area of each state. 

```r
# Here we set byid = TRUE 
State_area <- rgeos::gArea(OVENstates_raster, byid = TRUE)/10000
```

Combining the output into a data frame.

```r
# Get states within their distribution
State_area <- data.frame(State = OVENstates_raster$NAME_1,
                         Area_km = State_area)

head(State_area)
```

```
##                  State    Area_km
## 1              Alabama 6465488.15
## 2          Connecticut 7821423.16
## 3 District of Columbia  415567.39
## 4              Georgia 1285287.29
## 5             Illinois  515468.08
## 6              Indiana   16607.04
```

<a href="#TOP">back to top</a>
