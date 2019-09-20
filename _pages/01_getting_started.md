---
title: "System installation"
classes: wide
header:
  caption: 'Photo credit: **M. T. Hallworth**'
  image: assets/images/lookingUp.jpg
layout: single
permalink: /_pages/getting_started
sidebar:
  nav: SpatialWorkshop
  title: Get Spatial! Using R as GIS
authors: Michael T. Hallworth & Clark S. Rushing
---
<a name="TOP"></a>
{% include toc title="In This Activity" %}



Welcome to Get Spatial! Before working through the set of activities it's best to have a recent version of R and RStudio. 

For reference, these activities were written using R version 3.6.1 (2017-01-27) on a Windows machine (x86_64-pc-linux-gnu (64-bit))

<div style="background-color:rgba(0, 0, 0, 0.0470588); border-radius: 25px; text-align:center; vertical-align: middle; padding:3px 0; width: 600px; margin: auto; box-shadow: 4px 5px gray;">
<h2>Update R and RStudio</h2>
You can install or update to the latest version of <a href="https://cloud.r-project.org/"><code>R</code>here</a> and <a href="https://www.rstudio.com/products/rstudio/download/">RStudio here</a>
</div>
<br>
<br>
<a name="install.packages"></a>

## Install required packages 
Before starting, run the following code to get all the packages we use in the activities / tutorials. 



```r
install.packages(c("devtools","animation","dismo",
                   "gdalUtils","geosphere","ggplot2",
                   "gstat","ks","leaflet","lwgeom",
                   "maptools","mapview","raster",
                   "rasterVis","rgdal","rgeos","sf",
                   "sp","spatstat","tidyverse","velox"), dependencies = TRUE)

if(any(!(pkgs %in% installed.packages()))){
  install.packages(pkgs[!(pkgs %in% installed.packages())],
                   dependencies = TRUE)}
```



We also need some newer versions of packages that are only available on GitHub. Once you run the above code and/or have the <code>devtools</code> package you can get the required functions by running the following:

```r
devtools::install_github("tidyverse/rlang", build_vignettes = TRUE)
devtools::install_github("tidyverse/ggplot2")
```

<a href="#TOP">Back to top</a>

## On Mac 
Download [GDAL](https://trac.osgeo.org/gdal/wiki/DownloadingGdalBinaries) and install the .dmg file. 

Download the `rgdal` package from CRAN [found here](https://cran.r-project.org/web/packages/rgdal/index.html).

Place the downloaded rgdal_1.2-16.tgz in your Desktop folder

Run `install.packages("~/Desktop/rgdal_1.2-16.tgz", repos=NULL)`

Install `raster` and `sp` by running: `install.packages(c("sp","raster"),dependencies = TRUE)`
<br>
<hr>

<a href="#TOP">Back to top</a>

## Correct installation

```r
library(raster)
```

```
## Loading required package: sp
```

```r
library(sp)
library(rgeos)
```

```
## rgeos version: 0.5-1, (SVN revision 614)
##  GEOS runtime version: 3.5.0-CAPI-1.9.0 
##  Linking to sp version: 1.3-1 
##  Polygon checking: TRUE
```

```r
library(rgdal)
```

```
## rgdal: version: 1.4-4, (SVN revision 833)
##  Geospatial Data Abstraction Library extensions to R successfully loaded
##  Loaded GDAL runtime: GDAL 2.2.2, released 2017/09/15
##  Path to GDAL shared files: /usr/share/gdal/2.2
##  GDAL binary built with GEOS: TRUE 
##  Loaded PROJ.4 runtime: Rel. 4.8.0, 6 March 2012, [PJ_VERSION: 480]
##  Path to PROJ.4 shared files: (autodetected)
##  Linking to sp version: 1.3-1
```

Running Windows and interested in MODIS data? You will need <strong>OSGeo4W</strong> ([available for download here](https://trac.osgeo.org/osgeo4w/)) because it comes with a HDF4 driver.


*Setup instructions are based on a very helpful [post by Nick Eubank](http://www.nickeubank.com/wp-content/uploads/2015/10/RGIS1_SpatialDataTypes_part0_setup.html)*

<a href="https://raw.githubusercontent.com/mhallwor/mhallwor.github.io/develop/Rscripts/getting_started.R" target="_blank" class="btn btn--info">Download R script</a> Last modified: 2019-09-20 18:26:28
