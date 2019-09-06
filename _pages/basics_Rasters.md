---
title: "Introduction to raster data in R"
classes: wide
contributors: Clark S. Rushing
header:
  caption: 'Photo credit: **M. T. Hallworth**'
  image: assets/images/lookingUp.jpg
layout: single
permalink: /_pages/basics_Rasters
sidebar:
  nav: SpatialWorkshop
  title: Get Spatial! Using R as GIS
authors: Michael T. Hallworth
---
<a name="TOP"></a>

{% include toc title="In This Activity" %}


This activity will introduce you to working with raster data in R.

**R Skill Level:** Intermediate - this activity assumes you have a working knowledge of `R` 

Need to brush up on syntax and data classes in `R`? See <a href= "{{ site.baseurl }}/_pages/R_basics" target = "_blank">R basics</a> for a refresher.

<div style="background-color:rgba(0, 0, 0, 0.0470588); border-radius: 25px; text-align:center; vertical-align: middle; padding:3px 0; width: 600px; margin: auto; box-shadow: 4px 5px gray;">

<h1>Objectives & Goals</h1>      
<b>Upon completion of this activity, you will:</b>
<ul>
<li>know how to <strong>create</strong> and write rasters</li>   
<li>know how to do basic <strong>calculations</strong></li>
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

<a href="https://raw.githubusercontent.com/mhallwor/mhallwor.github.io/develop/Rscripts/basics_Rasters.R" target="_blank" class="btn btn--info">Download R script</a> Last modified: 2019-09-06 14:31:19

<hr> 

# What is a raster?    
A raster is a spatially explicit matrix or `grid` where each cell represents a geographic location. Each cell represents a pixel on a surface. The size of each pixel defines the resolution or `res` of raster. The smaller the pixel size the finer the spatial resolution. The `extent` or spatial coverage of a raster is defined by the minima and maxima for both x and y coordinates.

Rasters can be created from the following data classes:
<ui>
<li> Numeric </li>
<li> Integer </li>
<li> Categorical </li>
</ui>

## Raster formats 
Raster data are stored in a variety of formats. The table below shows several commonly encountered file types. Use <code>raster::writeFormats()</code> to see the full list. 


```
##      Name                  Long Name File Extension
## 1  raster                   R-raster           .grd
## 5     BIL               Band by Line           .bil
## 8   ascii                  Arc ASCII           .asc
## 22  GTiff                    GeoTIFF          .tiff
## 37 netCDF Network Common Data Format            .nc
```

# Creating & writing rasters   
## Raster data in R
Let's begin by creating a raster from scratch. We'll use the `raster` package to make an empty raster, set the `extent` and resolution (`res`) and assign values. Once we create a raster in R - we'll take a closer look at the metadata and structure of rasters in `R`.

load the `raster` package if you haven't already done so. If you need to install the `raster` package - see how to do that [here](#install.packages)

```r
# load library
library(raster)
```

Now that the `raster` library is loaded we can use the `raster()` function to create a raster in `R`. 

```r
# Create a raster from scratch using raster
firstRaster <- raster(xmn = -100,   # set minimum x coordinate
                      xmx = -60,    # set maximum x coordinate
                      ymn = 25,     # set minimum y coordinate
                      ymx = 50,     # set maximum y coordinate
                      res = c(1,1)) # resolution in c(x,y) direction
```

Here is what that raster looks like in `R`

```r
# Take a look at what the raster looks like
firstRaster
```

```
## class      : RasterLayer 
## dimensions : 25, 40, 1000  (nrow, ncol, ncell)
## resolution : 1, 1  (x, y)
## extent     : -100, -60, 25, 50  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0
```
Notice that the object is of `class: RasterLayer` has 25 rows, 40 columns and 1000 cells. The resolution (`res`) is 1x1 degree. The raster's `extent` ranges from -100 to -60 degrees longitude and 25 to 50 degrees latitude. The coordinate reference is WGS84 by default because `raster` recognized our inputs as degrees longitude/latitude. It doesn't always do so. 

<a href="#TOP">Back to top</a>

### Setting raster values
Currently there are no values associated with the raster layer we just created. It's empty. We can assign values to the raster in a few ways. We'll set the values of the raster using the `[]` convention. See the `setValues` function in the `raster` package for another way to set values of a raster. We'll sequence values from 1 to the number of cells within the raster. You can extract the number of cells within a raster using the `ncell` function.   
*note - the number of values you supply needs to be equivilant to the number of cells in the raster. You can however provide `NA` values.*

```r
# Assign values to raster 
firstRaster[] <- seq(from = 1, to = ncell(firstRaster),by = 1)

# Take a look at the raster now
firstRaster
```

```
## class      : RasterLayer 
## dimensions : 25, 40, 1000  (nrow, ncol, ncell)
## resolution : 1, 1  (x, y)
## extent     : -100, -60, 25, 50  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0 
## source     : memory
## names      : layer 
## values     : 1, 1000  (min, max)
```

You should now notice there are a few new attributes to our raster object. We gained `data source:`, `names` and `values` fields. The `data source` attribute tells us that the raster information is stored in our memory. The `names` field gave a name to the `values` we provided. The `values` we supplied are now contained in the `values` field. 

Now that the raster has values we can do a few things - like plot the raster.

```r
plot(firstRaster)
```

<img src="/figure/pages/basics_Rasters/plot-raster-1-1.png" title="plot of chunk plot-raster-1" alt="plot of chunk plot-raster-1" style="display: block; margin: auto;" />

<a href="#TOP">Back to top</a>

### Reading rasters from file

The `raster()` function within the `raster` package can also be used to read in a raster from file. Let's read in some <a href = "https://neo.sci.gsfc.nasa.gov/view.php?datasetId=MOD_NDVI_M&date=2018-01-01" target="_blank">Normalized Difference Vegetation Index (NDVI)</a> data from <a href="https://neo.sci.gsfc.nasa.gov/" target="_blank">NASA's NEO</a>. See <a href = "https://mhallwor.github.io/_pages/whereToGetData.html" target = "_blank">where to get data</a> for other potential data sources. 


```r
# read in raster layer using raster function
# NDVI <- raster("path/to/raster/file")
NDVI <- raster::raster("../Spatial_Layers/MOD_NDVI_M_2018-01-01_rgb_3600x1800.FLOAT.TIFF")
```

Let's take a look at the data

```r
NDVI
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

<img src="/figure/pages/basics_Rasters/unnamed-chunk-5-1.png" title="plot of chunk unnamed-chunk-5" alt="plot of chunk unnamed-chunk-5" style="display: block; margin: auto;" />
<div style="background-color: #ffffe6; border-radius: 25px; text-align:center; vertical-align: middle; padding: 3px 0; margin: auto; width:600px; box-shadow: 4px 5px #f2f2f2;"> 
<h3><strong>Challenge</strong></h3>
<strong>Does the NDVI appear as you expected?</strong>
<li> If not, why? </li>
<li> What needs to be done to make it fit your expectations?</li>
</div>
<img src="/figure/pages/basics_Rasters/unnamed-chunk-6-1.png" title="plot of chunk unnamed-chunk-6" alt="plot of chunk unnamed-chunk-6" style="display: block; margin: auto;" />

<a href="#TOP">Back to top</a>
