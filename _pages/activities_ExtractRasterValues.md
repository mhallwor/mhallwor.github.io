---
title: "Extracting raster data"
classes: wide
contributors: Clark S. Rushing
header:
  caption: 'Photo credit: **M. T. Hallworth**'
  image: assets/images/lookingUp.jpg
last_modified_at: 2019-06-13T18:44:19-4:00
layout: single
permalink: /_pages/activities_ExtractingRasterValues
sidebar:
  nav: SpatialWorkshop
  title: Get Spatial! Using R as GIS
authors: Michael T. Hallworth
---
{% include toc title="In This Activity" %}

<a name="TOP"></a>

**R Skill Level:** Intermediate - this activity assumes you have a working knowledge of `R` 

This activity incorporates the skills learned in the Points, Polygons, Raster & Projections activities.

<div style="background-color:rgba(186, 196, 214,0.47); border-radius: 25px; text-align:center; vertical-align: middle;
padding: 3px 0; width: 500px; margin: auto; box-shadow: 4px 5px gray;">
<h3> In case you missed it</h3>
<a href = "{{ site.baseurl }}/_pages/basics_SpatialPoints" target="_blank">SpatialPoints</a><br>
<a href = "{{ site.baseurl }}/_pages/basics_SpatialPolygons" target="_blank">SpatialPolygons</a><br>
<a href = "{{ site.baseurl }}/_pages/basics_Rasters" target="_blank">Rasters</a><br>
<a href = "{{ site.baseurl }}/_pages/projections" target="_blank">Projections</a><br>
</div>
<hr>


<div style="background-color:rgba(0, 0, 0, 0.0470588); border-radius: 25px; text-align:center; vertical-align: middle; padding:3px 0; width: 600px; margin: auto; box-shadow: 4px 5px gray;">

<h1>Objectives & Goals</h1>      
<b>Upon completion of this activity, you will:</b>
<ul>
<li>know how to <strong>extract</strong> raster data to spatial layers</li>   
<li>know how to <strong>summarize</strong> extracted data</li>
</ul>
</div>

<br>
<br>
<a name="install.packages"></a>
<div style="background-color:rgba(0, 1, 1, 0.0470588); border-radius: 25px; text-align:center; vertical-align: middle; padding:2px 0; width: 600px; margin: auto; box-shadow: 4px 5px gray;">
<h3> Required packages</h3> 
To complete the following activity you will need the following packages installed:

<strong>raster</strong>  
<strong>velox</strong> 
<strong>sp</strong>     
<strong>rgeos</strong>        
  
<h4>Installing the packages</h4>     
If installing these packages for the first time consider adding <code>dependencies=TRUE</code>   
<code>install.packages("raster")</code>     
<code>install.packages("velox")</code>    
<code>install.packages("sp")</code>        
<code>install.packages("rgeos")</code>   

</div>
        
<br>
<a href="https://raw.githubusercontent.com/mhallwor/mhallwor.github.io/develop/Rscripts/activities_ExtractRasterValues.R" target="_blank" class="btn btn--info">Download R script</a> Last modified: 2019-08-27 19:38:47
<hr>




```r
library(raster)
library(velox)
library(sp)
library(rgeos)
```

Extracting raster data to an area or location of interest is a common GIS task. There are a few things to keep in mind while extracting raster data in R. First, as we've seen in <code>Projections</code> it's best to use projected data. Second, make sure the two layers have the same <code>coordinate reference system</code>. Lastly, make sure you know the data class you're extracting (i.e., continuous, factor, etc.)

## Extracting Raster to SpatialPoints

Extracting raster data to <code>SpatialLayers</code> can be done using the <code>extract</code> function in the <code>raster</code> package. See <a href="https://www.rdocumentation.org/packages/raster/versions/2.6-7/topics/extract" target="_blank">extract function documentation</a> for details regarding options. 

### Gathering spatial data

For this first example, we'll use a digital elevation model (DEM) of Hubbard Brook Experimental Forest in New Hampshire. The dem is of class numerical. Which means we can perform numerical calculations like finding the mean and range of the data. Below, we'll use a data set where the data are factors.

Reading in the DEM

```r
# read in DEM of HBEF
DEM <- raster::raster("../Spatial_Layers/hb10mdem.txt")
```

Each summer, the Smithsonian Conservation Biology Institute's Migratory Bird Center conducts point counts at nearly 400 locations throughout Hubbard Brook. The point count locations have been georeferenced. Let's extract the elevation of each survey location. First, we'll need to read in the in the survey locations.  


```r
SurveyLocs <- raster::shapefile("../Spatial_Layers/hbef_valleywideplots.shp")
```


```
## class       : SpatialPointsDataFrame 
## features    : 395 
## extent      : 275500, 283000, 4866300, 4871200  (xmin, xmax, ymin, ymax)
## crs         : +proj=utm +zone=19 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0 
## variables   : 4
## names       : X8.digit.Pl, Plot.Tag, UTM.Eastin, UTM.Northi 
## min values  :    75567500,        1,     275500,    4866300 
## max values  :    83070200,       99,     283000,    4871200
```
Before we proceed, let's make sure the <code>CRS</code> is the same in for both the raster layer (DEM) and the <code>SpatialPoints</code> layer. 


```r
crs(SurveyLocs)
```

```
## CRS arguments:
##  +proj=utm +zone=19 +datum=NAD83 +units=m +no_defs +ellps=GRS80
## +towgs84=0,0,0
```

```r
crs(DEM)
```

```
## CRS arguments:
##  +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0
```

The two layers have different <code>coordinate reference systems</code>. We'll need to transform the <code>SpatialPoints</code> layer to match the raster (DEM). See <a href="{{site.baseurl}}/_pages/projections#projecting-rasters" target="_blank">caution projecting rasters</a> for details on why we'll project the <code>SpatialPoints</code> instead of the raster. 


```r
# Transform points to match CRS of the DEM
SurveyLocs_proj <- sp::spTransform(x = SurveyLocs,
                                   CRSobj = crs(DEM))
```

Now that the two layers have the same <code>CRS</code> we can extract the elevation to survey points. We'll use the <code>extract</code> function available in the raster package. The first argument is the raster values you want to extract. The second argument (y) can be a <code>SpatialObject</code> or matrix. 


```r
# Extract elevation to SpatialPoints
surveyElev <- raster::extract(x = DEM,
                              y = SurveyLocs_proj)
```

The resulting object is a vector with the same length as <code>SurveyLocs_proj</code>. 


```
##  num [1:395] 475 494 555 588 575 574 574 588 602 630 ...
```

We can add the data directly into the <code>SpatialPointsDataFrame</code> with the following code. 

```r
SurveyLocs_proj$Elev_m <- raster::extract(x = DEM,
                                          y = SurveyLocs_proj)
```


```
## class       : SpatialPointsDataFrame 
## features    : 395 
## extent      : -71.79809, -71.70358, 43.91606, 43.95997  (xmin, xmax, ymin, ymax)
## crs         : +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 
## variables   : 5
## names       : X8.digit.Pl, Plot.Tag, UTM.Eastin, UTM.Northi, Elev_m 
## min values  :    75567500,        1,     275500,    4866300,    240 
## max values  :    83070200,       99,     283000,    4871200,    965
```
![plot of chunk unnamed-chunk-12](/figure/pages/activities_ExtractRasterValues/unnamed-chunk-12-1.png)

## Extract raster to polygon/s

Below, we'll determine the proportion of landcover types within Alaska. In order to complete this task, some new functions will be introduced but we'll also use some skills we learned in other activities. 

### Gathering spatial data

We're interested in quantifying landcover around Anchorage, AK or more broadly the landcover types found in Alaska. 

First, we'll read in the landcover classes. In this example, we'll use landcover data with a relatively coarse resolution for simplicity and speed. 


```r
# Read in landcover data
LandCover <- raster::raster("../Spatial_Layers/MCD12C1_T1_2011-01-01_rgb_3600x1800.TIFF")
```

```
## class      : RasterLayer 
## dimensions : 1800, 3600, 6480000  (nrow, ncol, ncell)
## resolution : 0.1, 0.1  (x, y)
## extent     : -180, 180, -90, 90  (xmin, xmax, ymin, ymax)
## crs        : +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 
## source     : /home/travis/build/mhallwor/mhallwor.github.io/Spatial_Layers/MCD12C1_T1_2011-01-01_rgb_3600x1800.TIFF 
## names      : MCD12C1_T1_2011.01.01_rgb_3600x1800 
## values     : 0, 255  (min, max)
```
<br>  
<style>
td, th {
    border: 1px solid #dddddd;
    text-align: left;
    padding: 8px;
}
</style>
<table>
<tr style="background-color:#dddddd"><th><b>Code</b></th><th><b>Land Cover Class</b></th></tr>
<tr><td>01</td><td>Evergreen Needleleaf forest</td></tr>
<tr><td>02</td><td>Evergreen Broadleaf forest</td></tr>
<tr><td>03</td><td>Deciduous Needleleaf forest</td></tr>
<tr><td>04</td><td>Deciduous Broadleaf forest</td></tr>
<tr><td>05</td><td>Mixed forest</td></tr>
<tr><td>06</td><td>Closed shrublands</td></tr>
<tr><td>07</td><td>Open shrublands</td></tr>
<tr><td>08</td><td>Woody savannas</td></tr>
<tr><td>09</td><td>Savannas</td></tr>
<tr><td>10</td><td>Grasslands</td></tr>
<tr><td>11</td><td>Permanent wetlands</td></tr>
<tr><td>12</td><td>Croplands</td></tr>
<tr><td>13</td><td>Urban and built-up</td></tr>
<tr><td>14</td><td>Cropland/Natural vegetation mosaic</td></tr>
<tr><td>15</td><td>Snow and ice</td></tr>
<tr><td>16</td><td>Barren or sparsely vegetated</td></tr>
<tr><td>17</td><td>Water bodies</td></tr>
<tr><td>18</td><td>Tundra</td></tr>
</table>

*National Center for Atmospheric Research Staff (Eds). Last modified 10 Feb 2017. "The Climate Data Guide: CERES: IGBP Land Classification." Retrieved from https://climatedataguide.ucar.edu/climate-data/ceres-igbp-land-classification.
<br>

Now that we have a basic Landcover layer, we'll can gather spatial data for Alaska. We'll grab the entire United States and then subset out Alaska. 

```r
States <- raster::getData("GADM", country = "United States", level = 1)
```


```r
AK <- States[States$NAME_1=="Alaska",]
```


```
## class       : SpatialPolygonsDataFrame 
## features    : 1 
## extent      : -179.1506, 179.7734, 51.20972, 72.6875  (xmin, xmax, ymin, ymax)
## crs         : +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 
## variables   : 10
## names       : GID_0,        NAME_0,   GID_1, NAME_1, VARNAME_1, NL_NAME_1, TYPE_1, ENGTYPE_1, CC_1, HASC_1 
## value       :   USA, United States, USA.2_1, Alaska, AK|Alaska,        NA,  State,     State,   NA,  US.AK
```
Great - now we have a <code>SpatialPolygonsDataFrame</code> of Alaska. Take note of the <code>CRS</code>. 

Landcover types are factors since they're categorical. The reason that's important is because when extracting raster data there are options to apply a function to the underlying raster data. For example, the <code>extract</code> function allows users to specify a function like <code>mean</code> and the function will return the mean raster value under the area of interest. However, because landcover types are factors, returning the mean landcover type is meaningless. Instead, as a final result were interested in having a table giving the percent of each landcover type in Alaska. We'll work our way up to that. We'll start by first extracting the landcover types in Alaska using the <code>extract</code> function available in the <code>raster</code> package.

The <code>velox</code> package is much faster for extracting raster values, especially with large data sets. See what else <code>velox</code> can do <a href="https://www.rdocumentation.org/packages/velox/versions/0.2.0" target="_blank">velox documentation</a> 

```r
# Extract using the raster package 

# x = raster layer
# y = SpatialLayer

a <- Sys.time()
AK_lc <- extract(x = LandCover,
                 y = AK)
Sys.time()-a
```

```
## Time difference of 2.366181 mins
```

```r
# Extract using velox 
LandCover_velox <- velox::velox(LandCover)

b <- Sys.time()
AK_lc_velox <- LandCover_velox$extract(AK)
Sys.time() - b
```

```
## Time difference of 25.3777 secs
```
 
<div style="background-color: #ffffe6; border-radius: 25px; text-align:center; vertical-align: middle; padding: 3px 0; margin: auto; width:600px; box-shadow: 4px 5px #f2f2f2;"> 
<h4><strong>On your own:</strong></h4>
What does the <code>extract</code> function return? How are the data stored? How do you think the resulting object would differ if we had more than one <code>SpatialPolygon</code>?
</div>
<br>


```
## List of 1
##  $ : num [1:27934] NA 10 10 10 10 10 10 10 10 10 ...
```

The <code>extract</code> function returns a list with the raster values that fall within our area of interest. Let's summarize the data a little bit. We'll use the <code>table</code> function to briefly summarize the landcover types within Alaska. 

```r
table(AK_lc)
```

```
## AK_lc
##     1     3     4     5     7     8     9    10    11    13    14    15 
##   877     5     3   426 13745  6333    59  4264    25     2     5  1349 
##    16 
##     6
```

![plot of chunk unnamed-chunk-21](/figure/pages/activities_ExtractRasterValues/unnamed-chunk-21-1.png)



## Custom function to summarize landcover data # 

Let's write a simple function that returns the landcover data as a percentage. The first thing we'll do is make a sorted vector that has all the unique landcover types that are found in the landcover data set. 

```r
# sort the unique values in LandCover
z <- sort(unique(raster::values(LandCover)))
```


```
##  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16
```

Now that we have a sorted vector of all the landcover types in the LandCover raster - let's summarize the landcover types in Alaska. To do that we'll need to write a custom function. Our function will be called <code>summarizeLC</code>. The <code>summarizeLC</code> function will except three arguments: <code>x</code> = extracted landcover data, <code>LC_classes</code> = land cover classes in the data set & <code>LC_names</code> a vector that contains the names of the landcover types. We'll set <code>LC_names</code> = NULL so it's optional.


```r
summarizeLC <- function(x,LC_classes,LC_names = NULL){
               # Find the number of cells 
               y <- length(x)
               # Make a table of the cells
               tx <- table(x)
               # Create an empty array to store landcover data
               LC <- array(NA,c(1,length(LC_classes)))
               # Loop through the landcover types & return 
               # the number of cells within each landcover type
               for(i in seq(LC_classes)){
               LC[1,i] <- ifelse(LC_classes[i] %in% dimnames(tx)[[1]], 
                                 #if true
                                 tx[which(dimnames(tx)[[1]]==LC_classes[i])],
                                 # if false
                                 0) 
               } # end loop
               # Convert to percentage 
               LC <- LC/y
               # 
               if(!is.null(LC_names)){
                 colnames(LC)<-LC_names}
               else{colnames(LC)<-LC_classes}
        
               return(LC)
}
```

Here we'll apply our function to the extracted raster data. Remember, the extracted raster data (<code>AZ_lc</code>) are stored as a list. Because of that we'll use the <code>lapply</code> function to apply our function (<code>summarizeLC</code>) to all elements of a list. This is especially useful when you extract raster values to more than one polygon, as the extracted values are stored in separate lists. 


```r
summaryValues <- lapply(AK_lc,FUN = summarizeLC,LC_classes = z)
```

Here is what the final result may look like. 


```
##                                    Percent
## Evergreen Needleleaf forest          0.031
## Evergreen Broadleaf forest           0.000
## Deciduous Needleleaf forest          0.000
## Deciduous Broadleaf forest           0.000
## Mixed forest                         0.015
## Closed shrublands                    0.000
## Open shrublands                      0.492
## Woody savannas                       0.227
## Savannas                             0.002
## Grasslands                           0.153
## Permanent wetlands                   0.001
## Croplands                            0.000
## Urban and built-up                   0.000
## Cropland/Natural vegetation mosaic   0.000
## Snow and ice                         0.048
## Barren or sparsely vegetated         0.000
```

<div style="background-color: #ffffe6; border-radius: 25px; text-align:center; vertical-align: middle; padding: 3px 0; margin: auto; width:600px; box-shadow: 4px 5px #f2f2f2;"> 
<h4><strong>On your own:</strong></h4>
Find the proportion of each landcover type within your state. Use the <code>extract</code> function and the custom <code>summarizeLC</code> function return the landcover percentages.

<h4><strong>Challenge:</strong></h4>
Compare and contrast the landcover classes for two or more states.
</div>
<br>


```
##                                    New Hampshire West Virginia
## Deciduous Broadleaf forest                 0.111         0.905
## Mixed forest                               0.867         0.012
## Grasslands                                 0.000         0.002
## Urban and built-up                         0.011         0.003
## Cropland/Natural vegetation mosaic         0.004         0.078
```


<a href="#TOP">back to top</a>
