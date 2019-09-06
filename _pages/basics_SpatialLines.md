---
title: "Introduction to spatial lines in R"
authors: "Michael T. Hallworth"
contributors: "Clark S. Rushing"
layout: single
classes: wide
permalink: /_pages/basics_SpatialLines
header:
  caption: 'Photo credit: **M. T. Hallworth**'
  image: assets/images/lookingUp.jpg
sidebar:
  title: "Get Spatial! Using R as GIS"
  nav: "SpatialWorkshop"
last_modified_at:  "2018-04-09T21:19:43-4:00"
---
<a name="TOP"></a>
{% include toc title="In This Activity" %}


This activity will introduce you to working with spatial lines in R.

**R Skill Level:** Intermediate - this activity assumes you have a working knowledge of `R`     

<div style="background-color:rgba(0, 0, 0, 0.0470588); border-radius: 25px; text-align:center; vertical-align: middle; padding:3px 0; width: 600px; margin: auto; box-shadow: 4px 5px gray;">

<h1>Objectives & Goals</h1>      
<b>Upon completion of this activity, you will:</b>
<ul>
<li>Know how to <strong>create</strong> and write spatial lines</li>
<li>Know how to convert <strong>points to lines</strong></li>
<li>Be able to <strong>calculate distances</strong> along spatial lines</li>             
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

<a href="https://raw.githubusercontent.com/mhallwor/mhallwor.github.io/develop/Rscripts/basics_SpatialLines.R" target="_blank" class="btn btn--info">Download R script</a> Last modified: 2019-09-06 18:49:22

<hr>

```r
library(raster)
library(sp)
library(geosphere)
library(rgeos)
```

Creating spatial lines using the <code>sp</code> package is similar to making polygons from scratch - tedious. Here, for completeness we'll make a few spatial lines from scratch. Once we know how to do that, we'll use a simplier method. 

To construct lines we first need to start with the locations of the endpoints. For this example, we'll use the 100 random points we used for the <a href="{{ site.baseurl }}/_pages/basics_SpatialPoints" target="_blank">SpatialPoints</a> lession. Let's also add an <code>ID</code> field as well. 


```r
# generate 100 random XY coords 
x_coords <- runif(n = 100, min = -100, max = -80)
y_coords <- runif(n = 100, min = 25, max = 45)

# make a unique identifier for each line
ID <- paste0("line_",1:100)
```


```
##    x_coords y_coords     ID
## 1 -97.62565 37.62132 line_1
## 2 -80.02266 42.46848 line_2
## 3 -86.41110 41.55089 line_3
## 4 -83.78169 39.67623 line_4
## 5 -90.30912 34.40001 line_5
## 6 -91.27978 36.79996 line_6
```

Now that we have the endpoints, we need to create a <code>Line</code> object then convert that to a <code>Lines</code> object and give them an ID then we can finally convert them to <code>SpatialLines</code>. Here, we'll use the first two points for our first line.


```r
line_obj <- sp::Line(cbind(x_coords[1:2],y_coords[1:2]))

lines_obj <- sp::Lines(list(line_obj),ID=ID[1])

firstLine <- sp::SpatialLines(list(lines_obj))
```

The code to generate a series of lines from a list of points gets a bit ugly and creating lines from scratch isn't common - at least I haven't done it very often in my work. Here are a few 'easier' ways to create <code>SpatialLine</code> objects.

First using the <code>sp</code> package again. Here, we'll convert to <code>SpatialPoints</code> then use the <code>as</code> function to convert a <code>SpatialPoints</code> into a <code>SpatialLine</code>

```r
# make SpatialPoints
points <- sp::SpatialPoints(cbind(x_coords,y_coords))

# use as to convert to line
sp_line <- as(points,"SpatialLines")
```


```
## class       : SpatialLines 
## features    : 1 
## extent      : -99.77334, -80.02266, 25.00572, 44.88346  (xmin, xmax, ymin, ymax)
## crs         : NA
```

![plot of chunk unnamed-chunk-6](/figure/pages/basics_SpatialLines/unnamed-chunk-6-1.png)

<div style="background-color: #ffffe6; border-radius: 25px; text-align:center; vertical-align: middle; padding: 3px 0; margin: auto; width:600px; box-shadow: 4px 5px #f2f2f2;"> 
<h4><strong>One your own:</strong></h4>
How would you create a line with only the first 10 points instead of all of them? How would you make a line that included only the last 20 points?
</div>
<br>
![plot of chunk unnamed-chunk-7](/figure/pages/basics_SpatialLines/unnamed-chunk-7-1.png)

### Distance / length

Calculating the distance along a line / length of a line can be done using the <code>rgeos</code> package. It can also be done with the <code>sf</code> package. First, we'll use the <code>gLength</code> function. We need to be a little careful here because the units it returns depends on the <code>coordinate reference system</code> the data have. See <a href="{{ site.baseurl }}/_pages/projections" target="_blank">projections</a> for details. 


```r
# returns length in coordinate reference system units
# here it's degrees - it assumes planar coordinates
rgeos::gLength(sp_line)
```

```
## [1] 1040.025
```

Another option is to return the great circle distance. The following code calculates the great circle distance along a line and returns the distance in meters. 

```r
# great circle distance along our line
geosphere::lengthLine(sp_line)
```

```
## [1] 104684037
```

<div style="background-color: #ffffe6; border-radius: 25px; text-align:center; vertical-align: middle; padding: 3px 0; margin: auto; width:600px; box-shadow: 4px 5px #f2f2f2;"> 
<h4><strong>One your own:</strong></h4>
Find the great circle length in kilometers of a line that contains the first 25 locations.
</div>
<br>

<a href="#TOP">Back to top</a>
