---
title: "Projections"
classes: wide
contributors: Clark S. Rushing
header:
  caption: 'Photo credit: **M. T. Hallworth**'
  image: assets/images/lookingUp.jpg
layout: single
permalink: /_pages/projections
sidebar:
  nav: SpatialWorkshop
  title: Get Spatial! Using R as GIS
authors: Michael T. Hallworth
---
<a name="TOP"></a>


{% include toc title="In This Activity" %}

This activity will introduce you projecting spatial data R.

**R Skill Level:** Intermediate - this activity assumes you have a working knowledge of `R` 


<div style="background-color:rgba(0, 0, 0, 0.0470588); border-radius: 25px; text-align:center; vertical-align: middle; padding:3px 0; width: 600px; margin: auto; box-shadow: 4px 5px gray;">

<h1>Objectives & Goals</h1>      
<b>Upon completion of this activity, you will:</b>
<ul>
<li>know <strong>how</strong> and <strong>why</strong> to project data </li>  
<li>know where to <strong>find</strong> projection definitions</li>
<li>know how <strong>assign</strong> projections </li>
<li>know how to <strong>project</strong> spatial data</li>
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
</div>
        
<br>
<hr> 

<a href="https://raw.githubusercontent.com/mhallwor/mhallwor.github.io/master/Rscripts/projections.R" target="_blank" class="btn btn--info">Download R script</a> Last modified: 2019-07-19 19:56:35

# Projections
The reason we need projections is so that we can map a three dimensional surface - like the earth in two dimensional space. Unfortunately, not all properties of the 3D surface are maintained when plotting in 2D space. Attributes of the 3D surface such as area, distance, shape and direction are distorted when creating a 2D map. Projections define the way we distort the 3D surface in order to render it in 2D. The projection is the mathmatical equation used to 'flatten' the world. Every time we create a map we distort the true surface in some fashion. Different projections preserve different aspects of the 3D properties. Therefore, knowing which projections to use is important when doing spatial analyses. For example, if you're looking to create a map that looks 'correct' a conformal projection might be used as these types of projections preserve shape. If you're looking to make accurate distance measurements on a surface projections in the equidistant class are appropriate. Take a look at this <a href = "http://projections.mgis.psu.edu/" target="_blank">interactive map</a> that shows different projections - be sure to turn on the distortion ellipse so you can see how distortion changes. 

<img src="/figure/pages/projections/unnamed-chunk-2-1.png" title="plot of chunk unnamed-chunk-2" alt="plot of chunk unnamed-chunk-2" style="display: block; margin: auto;" />

<strong> Area of Greenland </strong>

|Projection| Area |
|---------|------|
|WGS84 (unproj)|661.2549217|
|Mollewide |214945256.262614|
|Robinson | 345229642.668977|
|Albers Eq Area |216118436.149343|

Projecting data in R isn't done automatically (for the most part) like it is in ArcMap (on the fly). That means that we need to:
<ul>
<li> <strong>know the projection</strong> of all spatial layers &</li>
<li> be sure they <strong>match</strong> </li>
</ul>

<a href="#TOP">back to top</a>

### Finding projection definitions
<a name="FindProj"></a>
Each projection has a set of 'instructions' on how to distort the earth. For a detailed explaination of each parameter in a `coordinate reference system` (crs) see <a href = "http://proj4.org/parameters.html" target="_blank">proj4.org </a>.<br>

Below are some of my 'go to' sites for finding projection definitions. 
<ui>
<li><a href = "http://spatialreference.org/" target="_blank"><strong>spatialreference.org</strong></a></li><br>
<li><a href = "http://proj4.org/projections/index.html" target="_blank"><strong>proj4.org</strong></a></li><br>
<li><a href = "http://www.epsg-registry.org/" target="_blank"><strong>EPSG-registry.org</strong></a></li><br>
</ui>

<a href="#TOP">back to top</a>

## Projecting spatial data

The good news is that it's quite simple to project spatial data in `R`. First, we need to know whether an object has a `coordinate reference system` (crs) or not. For the next few examples we'll use a `SpatialPolygonDataFrame` that we can get through the `raster` package. 

```r
States <- raster::getData(name = "GADM",
                             country = "United States",
                             level = 1,
                             path = "path/to/save/file",
                             download = TRUE)
# Take a look at the shapefile
States

# Let's remove Alaska and Hawaii for plotting purposes
States <- States[States$NAME_1 != "Alaska" & States$NAME_1 != "Hawaii",]
```


```
## class       : SpatialPolygonsDataFrame 
## features    : 52 
## extent      : -179.1506, 179.7734, 18.90986, 72.6875  (xmin, xmax, ymin, ymax)
## crs         : +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 
## variables   : 13
## names       : OBJECTID, ID_0, ISO,        NAME_0, ID_1,  NAME_1, HASC_1, CCN_1, CCA_1,           TYPE_1,        ENGTYPE_1, NL_NAME_1, VARNAME_1 
## min values  :        1,  244, USA, United States,    1, Alabama,  US.AK,    NA,      , Federal District, Federal District,          , AK|Alaska 
## max values  :       52,  244, USA, United States,   51, Wyoming,  US.WY,    NA,      ,            State,            State,          ,   WY|Wyo.
```

### Access projection of object
You can find the projection information under the `coord. ref.` field above. To access the coordinate reference system within the object you can do one of the following:

```r
# Use the crs() function in raster
raster::crs(States)
```

```
## CRS arguments:
##  +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0
```

```r
# access the projection slot directly
States@proj4string
```

```
## CRS arguments:
##  +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0
```

```r
# access projection as character 
# - this can be very useful when 
#   using the projection of one
#   object to project another
States@proj4string@projargs
```

```
## [1] "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
```

### Projection using `sp` package
Projecting data in `R` is very straightforward. The `spTransform` function found in the `sp` package makes projecting `Spatial` objects possible with only a single line of code. Let's change the projection from WGS84 into North America Lambert Equal Area. See [where to find projections](#FindProj) for where to find a definition for the North America Lambert Equal Area projection. There are two ways to assign the projection. First is to include a string of the <a href = "proj4.org" target="_blank">proj4</a> definition. The second is to refer to the EPSG authority number. Best practice is to use the EPSG code because the database is updated and if changes occur to the projection it will update your map accordingly if you re-run the code. Providing a character string of the projection does will not automatically update unless you manually go back and change the values. One benefit to using a character string (in my opinion) is that it's easy to manually create new projections with different central maridens that likely aren't predefined. 


```r
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
```

<img src="/figure/pages/projections/unnamed-chunk-3-1.png" title="plot of chunk unnamed-chunk-3" alt="plot of chunk unnamed-chunk-3" style="display: block; margin: auto;" />

Let's remove the `coordinate reference system` (crs) from `States` then try to project it and see what happens. 

```r
crs(States)<-NA
States
```

```
## class       : SpatialPolygonsDataFrame 
## features    : 49 
## extent      : -124.7628, -66.94889, 24.52042, 49.3833  (xmin, xmax, ymin, ymax)
## crs         : NA 
## variables   : 13
## names       : OBJECTID, ID_0, ISO,        NAME_0, ID_1,  NAME_1, HASC_1, CCN_1, CCA_1,           TYPE_1,        ENGTYPE_1, NL_NAME_1, VARNAME_1 
## min values  :        1,  244, USA, United States,    1, Alabama,  US.AL,    NA,      , Federal District, Federal District,          ,   AL|Ala. 
## max values  :       52,  244, USA, United States,   51, Wyoming,  US.WY,    NA,      ,            State,            State,          ,   WY|Wyo.
```

### Defining projection to `SpatialObject`

If your `SpatialObject` doesn't have a `coordinate reference system` (crs) defined it won't know how to project the data. Therefore, if the `coordinate reference system` (crs) is `NA` you need to assign it. <strong>A word of caution</strong> - `R` will let you assign any valid PROJ.4 CRS string as the `coordinate reference system` to an object even if it doesn't make sense.   

```r
# Let's take a look at the extent of the 
# shapefile to give us a clue to what projection
# it may be. 
States
```

```
## class       : SpatialPolygonsDataFrame 
## features    : 49 
## extent      : -124.7628, -66.94889, 24.52042, 49.3833  (xmin, xmax, ymin, ymax)
## crs         : NA 
## variables   : 13
## names       : OBJECTID, ID_0, ISO,        NAME_0, ID_1,  NAME_1, HASC_1, CCN_1, CCA_1,           TYPE_1,        ENGTYPE_1, NL_NAME_1, VARNAME_1 
## min values  :        1,  244, USA, United States,    1, Alabama,  US.AL,    NA,      , Federal District, Federal District,          ,   AL|Ala. 
## max values  :       52,  244, USA, United States,   51, Wyoming,  US.WY,    NA,      ,            State,            State,          ,   WY|Wyo.
```

The `States` object appears to have a `+proj=longlat` since the extent of the object is in degrees longitude, latitude. Below we'll assign the WGS84 projection. 

```r
# Define WGS84 in proj4 string format
WGS84 <- "+proj=longlat +datum=WGS84 
          +no_defs +ellps=WGS84 +towgs84=0,0,0"

# use the crs() function in the raster package
# to define the projection
crs(States) <- WGS84

# take a look
States
```

```
## class       : SpatialPolygonsDataFrame 
## features    : 49 
## extent      : -124.7628, -66.94889, 24.52042, 49.3833  (xmin, xmax, ymin, ymax)
## crs         : +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 
## variables   : 13
## names       : OBJECTID, ID_0, ISO,        NAME_0, ID_1,  NAME_1, HASC_1, CCN_1, CCA_1,           TYPE_1,        ENGTYPE_1, NL_NAME_1, VARNAME_1 
## min values  :        1,  244, USA, United States,    1, Alabama,  US.AL,    NA,      , Federal District, Federal District,          ,   AL|Ala. 
## max values  :       52,  244, USA, United States,   51, Wyoming,  US.WY,    NA,      ,            State,            State,          ,   WY|Wyo.
```

<a href="#TOP">back to top</a>

## Projecting Rasters

<strong>Word of caution</strong>: Consider the following when using raster data for analyses. In general it's not the best approach to project rasters. Below is a brief description for why it's not a great idea to project rasters. The text below is borrowed <strong>heavily</strong> from <a href="http://rspatial.org/spatial/rst/6-crs.html#transforming-raster-data" target ="_blank">rspatial.org</a>, a blog written by Robert Hijmans - the author of the <code>raster</code> package. 
Vector data can be transformed to and from different projections without losing precision. However, that is not true with raster data. Because rasters consist of rectangular cells that are the same size with respect to the CRS units, their actual size may vary. It's not possible to transform a raster cell by cell. Therefore, estimates for the values of new cells are made based on the values in the old cells. A commonly used approach to estimating the values of the new cells is 'nearest neighbor'. Otherwise an interpolation (e.g. 'bilinear') approach is used - this can be set by the user when projecting rasters using the <code>projectRaster</code> function. Because projecting rasters affects cell values, in most cases you will want to avoid projecting raster data and project <code>SpatialObjects</code> instead.

For mapping purposes we'll go over how to project rasters. 

Let's grab a raster we are already familiar with. We'll use the NDVI raster from January 2018.

```r
# read in raster layer using raster function
# NDVI <- raster("path/to/raster/file")
NDVI <- raster::raster("../Spatial_Layers/MOD_NDVI_M_2018-01-01_rgb_3600x1800.FLOAT.TIFF")
```


```
## class      : RasterLayer 
## dimensions : 1800, 3600, 6480000  (nrow, ncol, ncell)
## resolution : 0.1, 0.1  (x, y)
## extent     : -180, 180, -90, 90  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 
## source     : /home/travis/build/mhallwor/mhallwor.github.io/Spatial_Layers/MOD_NDVI_M_2018-01-01_rgb_3600x1800.FLOAT.TIFF 
## names      : MOD_NDVI_M_2018.01.01_rgb_3600x1800.FLOAT
```

The NDVI raster is pretty large. It has 6480000 cells. It takes a little while to project the raster. 

```r
a <- Sys.time()
NDVIproj <- raster::projectRaster(from = NDVI,
                          crs = sp::CRS("+init=epsg:5070"))
Sys.time()-a
```


```
## class      : RasterLayer 
## dimensions : 4332, 4922, 21322104  (nrow, ncol, ncell)
## resolution : 6880, 5060  (x, y)
## extent     : -16935118, 16928242, -7001394, 14918526  (xmin, xmax, ymin, ymax)
## crs        : +proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=23 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs 
## source     : /home/travis/build/mhallwor/mhallwor.github.io/Spatial_Layers/MOD_NDVI_M_2018-01-01_rgb_3600x1800.FLOAT_proj.tif 
## names      : MOD_NDVI_M_2018.01.01_rgb_3600x1800.FLOAT_proj 
## values     : -5.768277, 100005.5  (min, max)
```

<img src="/figure/pages/projections/unnamed-chunk-9-1.png" title="plot of chunk unnamed-chunk-9" alt="plot of chunk unnamed-chunk-9" style="display: block; margin: auto;" />

<div style="background-color: #ffffe6; border-radius: 25px; text-align:center; vertical-align: middle; padding: 3px 0; margin: auto; width:600px; box-shadow: 4px 5px #f2f2f2;"> 
<h4><strong>On your own:</strong></h4>
Compare the number of cells <code>raster::ncell(raster)</code> before and after projecting the raster. Are they the same or are they different? If they're different, why do you think they differ? 
</div>
<br>

<a href="#TOP">back to top</a>




