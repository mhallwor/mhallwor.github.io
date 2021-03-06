---
title: "Get Spatial! Using R as GIS"
header:
  caption: 'Photo credit: **M. T. Hallworth**'
  image: assets/images/lookingUp.jpg
last_modified_at: 2018-04-04T11:00:19-4:00
layout: single
permalink: /_pages/breakdown_AOS19AK
sidebar:
  nav: SpatialWorkshop
  title: Get Spatial! Using R as GIS
classes: wide
authors: Michael T. Hallworth & Clark S. Rushing
---


   
### Schedule
Below is the tentative schedule for the workshop. We've allowed 30 mins at the end of the workshop for a little bit of wiggle room in case some activities take longer than expected. <br>

<table style="font-family:arial,sans-serif; border-collapse:collapse; width:60%;">
<tr><th>Time</th><th>Activity</th></tr>
<tr><td>8:00-10:00</td><td>The Basics (points,lines,polygons,rasters)</td></tr>
<tr style="background-color:#dddddd"><td>10:00-10:20</td><td>Break</td></tr>
<tr><td>10:20-11:00</td><td>Coordinate Reference Systems</td></tr>
<tr><td>11:00-12:00</td><td>Making maps</td></tr>
<tr style="background-color:#dddddd"><td>12:00-13:00</td><td>Lunch break</td></tr>
<tr><td>13:00-14:00</td><td>Spatial Predicates</td></tr>
<tr><td>14:00-15:00</td><td>Point-based analyses</td></tr>
<tr style="background-color:#dddddd"><td>15:00-15:20</td><td>Break</td></tr>
<tr><td>15:20-16:30</td><td>Advanced rasters</td></tr>
<tr><td>16:30-17:00</td><td>Wrap up</td></tr>
</table>
    
<br> 
     
### Welcome to Get Spatial! 
  
<b>Get Spatial! Using R as GIS</b> is a workshop intended to introduce participants to using the free, open-source program <code>R</code> as a geographic information system providing participants with an alternative to ArcMap or other proprietary GIS software. 

The objective of the workshop is to introduce and provide participants with working examples of how to use <code>R</code> for spatial analyses and map making. Specifically, in this full day workshop participants will learn 1) how to create and manipulate spatial layers (points, lines, polygons, rasters, projecting data) and 2) how to incorporate spatial data into analyses. 

The workshop will be comprised of morning and afternoon sessions. The morning session will be devoted to introductory material such as learning how to read, obtain and manipulate, and plot spatial data. Participants will learn how to import and export common types of spatial data (rasters & shapefiles), perform common manipulations (overlay, mask, subset), change projections, and visualize data. In addition, participants will learn how to use common <code>tidyverse</code> packages (<code>dplyr, tidyr, ggplot2</code>) to integrate spatial data into analysis and visualization workflows.

The afternoon will focus on applying the techniques learned in the morning session to questions relevant to ornithologists. For example, participants will: 1) create isoscapes and assign individuals to natal origins using stable-hydrogen isotopes; 2) Use territory mapping data to create home-ranges, visualize territory boundaries, and extract territory-level environmental data; 3) Obtain, read, and manipulate remotely sensed climate and habitat data to extract environmental covariates at point-count locations and integrate these data into occupancy and abundance models. 

<img src="https://amornithmeeting.files.wordpress.com/2018/08/aos2019-logo-horizontal_hashtag_side-txt_lower-banner_transparent_smaller.png">

## Birds & <i>Ornithologists</i> on the Edge: Dynamic Boundaries
![plot of chunk unnamed-chunk-2](/figure/pages/breakdown_ASO19AK/unnamed-chunk-2-1.png)

<style>
td, th {
    border: 1px solid #dddddd;
    text-align: left;
    padding: 8px;
}
</style>

