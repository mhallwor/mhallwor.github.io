---
title: "Working with Point-Count like data"
authors: "Michael T. Hallworth"
contributors: "Clark S. Rushing"
layout: single
classes: wide
permalink: /_pages/activities_PointCount
header:
  caption: 'Photo credit: **M. T. Hallworth**'
  image: assets/images/lookingUp.jpg
sidebar:
  title: "Get Spatial! Using R as GIS"
  nav: "SpatialWorkshop"
---

<a name="TOP"></a>
{% include toc title="In This Activity" %}

**R Skill Level:** Intermediate - this activity assumes you have a working knowledge of `R` 


<div style="background-color:rgba(0, 0, 0, 0.0470588); border-radius: 25px; text-align:center; vertical-align: middle; padding:3px 0; width: 600px; margin: auto; box-shadow: 4px 5px gray;">

<h1>Objectives & Goals</h1>      
<b>Upon completion of this activity, you will:</b>
<ul>
<li> <strong>Generate random points</strong> within a polygon </li>
<li> Create a <strong>buffer</strong> around the points</li>
<li> <strong>Extract</strong> raster data to points </li>
<li> predict occupancy and generate a surface using <strong>raster calculations</strong></li>
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

<a href="https://raw.githubusercontent.com/mhallwor/mhallwor.github.io/develop/Rscripts/activities_PointCount.R" target="_blank" class="btn btn--info">Download R script</a> Last modified: 2019-09-06 15:53:35

<hr> 

# Point-count like data
For this activity, let's assume you're getting ready to start a new project. In this project the primary form of data collection is through the use of point counts. Let's assume you already know you want to survey birds within the <a href="https://www.fs.usda.gov/main/coronado/home" target="_blank">Coronado National Forest</a> the system in which you want to survey. 


```r
library(raster)
library(sp)
library(rgeos)
```

Read in a shapefile that contains information about the national forest boundaries in the United States. The shapefile was downloaded from <a href ="https://data.fs.usda.gov/geodata/edw/datasets.php?dsetCategory=boundaries" target="_blank"> here </a>


```r
# Read in Administrative forest boundaries 
# This shapefile has boundary information
# for forests the U.S. federal govt is
# responsible for - i.e., National Forests,
# National Monuments, etc. 

NatForest <- raster::shapefile("../Spatial_Layers/S_USA.AdministrativeForest.shp")

# Take a glance at the file
NatForest
```

```
## class       : SpatialPolygonsDataFrame 
## features    : 112 
## extent      : -150.0079, -65.69967, 18.03373, 61.51899  (xmin, xmax, ymin, ymax)
## crs         : +proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,0 
## variables   : 8
## names       :                           ADMINFORES, REGION, FORESTNUMB, FORESTORGC,                 FORESTNAME,     GIS_ACRES,      SHAPE_AREA,      SHAPE_LEN 
## min values  :                       99010200010343,     01,         01,       0102,  Allegheny National Forest,     27566.061, 0.0120072002574, 0.754287568301 
## max values  : e23b8205-a516-4aa3-945e-5dd93dbfe227,     10,         60,       1005, Willamette National Forest, 17684857.9312,   10.5984390953,  378.929375922
```

Let's pull out just the Coronado National Forest. Here we use the <code>grep()</code> function to search for 'Coronado' within the <code>FORESTNAME</code> field. 

```r
CNF <- NatForest[grep(x=NatForest$FORESTNAME,pattern="Coronado"),]
```

We're going to need a Digital Elevation Model (DEM) for our analysis. For convience we'll grab a DEM using the 'alt' (elevation) data set available with the raster package. Note - when using the raster to download elevation in the United States - a list is returned. The first element of the list is the elevation (in meters) of the contiguous states. The other elements include Alaska, and Hawaii.

```r
# Get elevation data using the raster package
DEM <- raster::getData(name = "alt", country = "United States")
```

```
## returning a list of RasterLayer objects
```

```r
# Save only the elevation in the lower 48
DEM <- DEM[[1]]
```

![plot of chunk plot-CNF](/figure/pages/activities_PointCount/plot-CNF-1.png)

<a href="#TOP">Back to top</a>

## Generate point count locations
The <code>sp</code> package has a function to generate random points. It has a few options but here we'll use <code>type = "regular"</code> to generate random points that are systematically aligned. The <code>n</code> is the approximate sample size. We'll also set the seed for the random number generator so you should get the same locations. 


```r
set.seed(12345)

surveyPts <- sp::spsample(x = CNF, n = 100, type = "regular")
```

Let's take a look at how many sites were generated and where they ended up. 

```r
plot(CNF)
plot(surveyPts, add = TRUE, pch = 19)
```

![plot of chunk unnamed-chunk-5](/figure/pages/activities_PointCount/unnamed-chunk-5-1.png)

<a href="#TOP">Back to top</a>

## Generate buffer around points
Now that we have generate survey points - let's make a 50m radius around each point.

Before we go any further we need to know a few things. We need to know if the <code>coordinate reference system (crs)</code> is defined for our survey points and we also need to what the <code>crs</code> is. To make our lives easier if would be good to have the surveyPoints projected into an Equal Area projection in meters. The reason for this is two-fold. First, an equal area projection will conserve area so our buffers should be accurate and second, if it's in a meters we can specify the <code>width</code> parameter in meters. 


```r
surveyPts
```

```
## class       : SpatialPoints 
## features    : 98 
## extent      : -111.3911, -108.9843, 31.40503, 32.98191  (xmin, xmax, ymin, ymax)
## crs         : +proj=longlat +datum=NAD83 +no_defs +ellps=GRS80 +towgs84=0,0,0
```

Project the points into an equal area projection. While we're at it - let's project all our layers (DEM, forest boundaries, and survey points).

```r
# Define the projection in proj4 format
EqArea <- "+proj=aea 
           +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 
           +ellps=GRS80 
           +datum=NAD83 
           +units=m +no_defs"

# project data using the sp package
surveyPts_m <- sp::spTransform(surveyPts, sp::CRS(EqArea))

# project forest boundary
CNF_m <- sp::spTransform(CNF, sp::CRS(EqArea))
```

Now for the DEM - it's quite large and we only need a small portion. Let's crop the DEM to include only the area around Coronado National Forest.


```r
DEM <- crop(DEM,CNF)

# take a look
DEM
```

```
## class      : RasterLayer 
## dimensions : 201, 304, 61104  (nrow, ncol, ncell)
## resolution : 0.008333333, 0.008333333  (x, y)
## extent     : -111.45, -108.9167, 31.33333, 33.00833  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +ellps=WGS84 
## source     : memory
## names      : USA1_msk_alt 
## values     : 447, 3172  (min, max)
```


```r
DEM_m <- projectRaster(DEM, crs = EqArea)
```

Now that we've projected the data we can generate the 50m radius around each point. To do this make sure to use <code>byid = TRUE</code>.

```r
library(rgeos)
surveyCircle <- gBuffer(surveyPts_m, width = 50, byid = TRUE)
```

Extract elevation to the survey locations

```r
pt_elev <- extract(DEM_m, surveyCircle, fun = mean, na.rm = TRUE)
```

![plot of chunk unnamed-chunk-12](/figure/pages/activities_PointCount/unnamed-chunk-12-1.png)

<a href="#TOP">Back to top</a>

### Simulate count data 
We'll simulate occupancy data using a function from Kery & Royle 2016 <a href = "https://www.mbr-pwrc.usgs.gov/pubanalysis/keryroylebook/" target="_blank">Applied Hierarchical Modeling in Ecology</a>. Here we use the simOcc function saving most of the preset values. We just want the count data so I save only the <code>y</code> ouput. 




```r
#library(AHMbook)
#library(unmarked)

# Simulate occupancy data
# M = number of sites 
# J = number of occassions

simCount <- AHMbook::simOcc(M = length(surveyPts), 
                            J = 3, 
                            mean.occupancy = 0.6, 
                            mean.detection = 0.7,
                            show.plot = FALSE)$y

# see first few rows
head(simCount)
```

```
##      [,1] [,2] [,3]
## [1,]    1    1    1
## [2,]    0    0    0
## [3,]    1    0    0
## [4,]    0    1    1
## [5,]    1    1    1
## [6,]    1    1    1
```

Using these simulated data, we'll determine the relationship between elevation and occupancy while accounting for imperfect detection using the <code>unmarked</code> package. 

```r
# Make unmarked frame for occupancy data
umf <- unmarked::unmarkedFrameOccu(y = simCount, 
                                   siteCovs=data.frame(pt_elev), 
                                   obsCovs=NULL)

# run the occupancy model
occ <- unmarked::occu(~1~pt_elev,umf)
```

<a href="#TOP">Back to top</a>

## Map occupancy probability 

Let's create a map of the predicted occupancy probabilty throughout the Coronado National Forest. We'll use the parameter estimates from the occupancy model we ran above. 


```r
occMap <- exp(unmarked::coef(occ)[1]+unmarked::coef(occ)[2]*DEM_m)/
          (1+exp(unmarked::coef(occ)[1]+unmarked::coef(occ)[2]*DEM_m))

plot(mask(occMap, CNF_m),col = bpy.colors(30))
```

![plot of chunk unnamed-chunk-16](/figure/pages/activities_PointCount/unnamed-chunk-16-1.png)


<a href="#TOP">Back to top</a>
