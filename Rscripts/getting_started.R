## ----echo = FALSE--------------------------------------------------------
knitr::opts_chunk$set(fig.width=10)


## ----echo = FALSE, comment = "",warning = FALSE--------------------------
#packagesNeeded <- readLines("../DEPENDS.txt")
#pkgs <- paste0(packagesNeeded,collapse = ",")
#pkgs <- gsub(x = pkgs, pattern = ",", replacement = '","')
#cat("install.packages(c(",'"',"devtools",'","',pkgs,'"',"), dependencies = TRUE)",sep="")


## ---- eval = FALSE-------------------------------------------------------
## install.packages(c("devtools","animation","dismo",
##                    "gdalUtils","gstat","ks","leaflet",
##                    "lwgeom","maps","maptools","mapview",
##                    "raster","rasterVis","rgdal","rgeos",
##                    "sf","sp","spatstat","tidyverse","velox"))
## 
## if(any(!(pkgs %in% installed.packages()))){
##   install.packages(pkgs[!(pkgs %in% installed.packages())],
##                    dependencies = TRUE)}


## ----echo = FALSE, message = FALSE,warning = FALSE,results='hide'--------
pkgs <- c("devtools","animation","dismo",
          "gdalUtils","gstat","ks","leaflet",
          "lwgeom","maps","maptools","mapview",
          "raster","rasterVis","rgdal","rgeos",
          "sf","sp","spatstat","tidyverse","velox")

if(any(!(pkgs %in% installed.packages()))){install.packages(pkgs[!(pkgs %in% installed.packages())], dependencies = TRUE)}


## ----eval = FALSE--------------------------------------------------------
## devtools::install_github("tidyverse/rlang", build_vignettes = TRUE)
## devtools::install_github("tidyverse/ggplot2")


## ----warning = FALSE-----------------------------------------------------
library(raster)
library(sp)
library(rgeos)
library(rgdal)

