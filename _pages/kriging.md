---
title: "Spatial Interpolation"
classes: wide
contributors: Clark S. Rushing
header:
  caption: 'Photo credit: **M. T. Hallworth**'
  image: assets/images/lookingUp.jpg
last_modified_at: 2018-04-02T13:19:19-4:00
layout: single
permalink: /_pages/interpolation
sidebar:
  nav: SpatialWorkshop
  title: Get Spatial! Using R as GIS
authors: Michael T. Hallworth
---
<a name="TOP"></a>

{% include toc title="In This Activity" %}

This activity will introduce you to spatial interpolation in R.

**R Skill Level:** Intermediate - this activity assumes you have a working knowledge of `R` 

This activity incorporates the skills learned in the Points, Raster & Projections activities.

<div style="background-color:rgba(186, 196, 214,0.47); border-radius: 25px; text-align:center; vertical-align: middle;
padding: 3px 0; width: 500px; margin: auto; box-shadow: 4px 5px gray;">
<h3> In case you missed it</h3>
<a href = "{{ site.baseurl }}/_pages/basics_SpatialPoints" target="_blank">SpatialPoints</a><br>
<a href = "{{ site.baseurl }}/_pages/basics_Rasters" target="_blank">Rasters</a><br>
<a href = "{{ site.baseurl }}/_pages/projections" target="_blank">Projections</a><br>
</div>
<hr>

<div style="background-color:rgba(0, 0, 0, 0.0470588); border-radius: 25px; text-align:center; vertical-align: middle; padding:3px 0; width: 600px; margin: auto; box-shadow: 4px 5px gray;">

<h1>Objectives & Goals</h1>      
<b>Upon completion of this activity, you will:</b>
<ul>
<li>know how to <strong>interpolate</strong> using <strong>inverse distance weighting</strong></li>   
<li>know how to use <strong>ordinary kriging</strong> to predict across a surface</li>
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
<strong>gstat</strong>          
<strong>spatstat</strong>             
  
<h4>Installing the packages</h4>     
If installing these packages for the first time consider adding <li><code>dependencies=TRUE</code></li>   
<li><code>install.packages("raster")</code></li>   
<li><code>install.packages("sp")</code></li>        
<li><code>install.packages("gstat")</code></li>   
<li><code>install.packages("spatstat")</code></li> 

</div>
        
<br>

<a href="https://raw.githubusercontent.com/mhallwor/mhallwor.github.io/develop/Rscripts/kriging.R" target="_blank" class="btn btn--info">Download R script</a> Last modified: 2019-09-06 18:49:22

<hr>

<b>This is still very much a work in progress</b>

One basic principle of geography is that variables that are close in space typically have similar values. We can use this principle to make predictions and interpolate a smooth surface from data sampled at points. There are a few ways to do this. Generally, when people refer to 'kriging' they are referring to interpolation. 

The following examples will use the raw number of species detected along breed bird survey (BBS) routes within Arizona. The data were summarized for brevity but the data represent the number of species detected along each route through time. We didn't do any formal analysis that accounts for imperfect detection. We just wanted some real data to illustrate interpolation.


```r
library(raster)
library(sp)
library(gstat)
library(spatstat)
```


```r
load("../Spatial_Layers/spproute.rda")
```

![plot of chunk unnamed-chunk-4](/figure/pages/kriging/unnamed-chunk-4-1.png)

Now that we have some data let's interpolate (predict values for locations were we have no data) species richness across Arizona.

Let's make an empty raster so that we can predict species richness across AZ. We'll use this several times so we'll go ahead and make it here. 

```r
# Spatial grid over the extent of sppStateRoute
# approximately 5000 random points
# set.seed() makes sure the random points are the same each time
# increases reproducability 

set.seed(12345)
samplegrid <- raster::raster(sppStateRoute,res = c(0.025,0.025))

# define CRS
raster::crs(samplegrid) <- raster::crs(sppStateRoute) <- sp::CRS("+init=epsg:4326")
```

We'll use the <code>gstat</code> package to interpolate species richness using a few different methods.

### Inverse distance weighting


```r
idw.model <- gstat(formula=sppStateRoute$SpeciesDetected~1, 
                   locations=sppStateRoute)

idw.spp <- raster::interpolate(samplegrid, idw.model)
```

```
## [inverse distance weighted interpolation]
```

```
## class      : RasterLayer 
## dimensions : 221, 222, 49062  (nrow, ncol, ncell)
## resolution : 0.025, 0.025  (x, y)
## extent     : -114.6683, -109.1183, 31.38823, 36.91323  (xmin, xmax, ymin, ymax)
## crs        : +init=epsg:4326 +proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 
## source     : memory
## names      : var1.pred 
## values     : 11.42869, 75.10614  (min, max)
```

Let's use the <code>mask</code> function to clip the raster to Arizona. 

```r
idw.spp.az <- raster::mask(idw.spp, States[States$NAME_1=="Arizona",])

par(bty="n",mar = c(0,0,0,0))
raster::plot(idw.spp.az,
             axes = FALSE,
             legend.args = list("Species\nRichness"))
plot(States, add = TRUE)
```

![plot of chunk unnamed-chunk-8](/figure/pages/kriging/unnamed-chunk-8-1.png)

### Ordinary Kriging 

```r
# remove duplicate locations because otherwise Kriging returns NA
sppStateRoute <- sppStateRoute[-sp::zerodist(sppStateRoute)[,1],]

# create variogram 
vario <- variogram(sppStateRoute$SpeciesDetected~1, sppStateRoute)
```



![plot of chunk unnamed-chunk-11](/figure/pages/kriging/unnamed-chunk-11-1.png)


```r
vario.fit <- fit.variogram(vario,
                           vgm(psill=250, # approx asymptote
                               range = 150,
                               model="Exp", 
                               nugget=50))

predict.model <- gstat(g=NULL,
                      formula = sppStateRoute$SpeciesDetected~1,
                      locations = sppStateRoute, 
                      model=vario.fit)

# make an empty raster to predict on #

r <- raster(ext = extent(sppStateRoute),
            res = c(0.025, 0.025), # same res as above
            crs = crs(sppStateRoute)@projargs)

# using ordinary kriging #
SpeciesRichness <- raster::interpolate(object = r, model = predict.model)
```

```
## [using ordinary kriging]
```

If you receive warnings that look similar to below, you have duplicate locations in your data. See above for how to remove duplicate locations.

```r
Covariance matrix singular at location [-114.543,36.7882,0]: skipping...
```

![plot of chunk unnamed-chunk-14](/figure/pages/kriging/unnamed-chunk-14-1.png)

<a href="#TOP">back to top</a>
