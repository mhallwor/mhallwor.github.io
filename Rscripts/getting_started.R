## ----echo = FALSE, comment = ""------------------------------------------
packagesNeeded <- readLines("../DEPENDS.txt")
pkgs <- paste0(packagesNeeded,collapse = ",")
pkgs <- gsub(x = pkgs, pattern = ",", replacement = '","')
cat("install.packages(c(",'"',"devtools",'","',pkgs,'"',"), dependencies = TRUE)",sep="")

## ----eval = FALSE--------------------------------------------------------
## devtools::install_github("tidyverse/rlang", build_vignettes = TRUE)
## devtools::install_github("tidyverse/ggplot2")

## ----warning = FALSE-----------------------------------------------------
library(raster)
library(sp)
library(rgeos)
library(rgdal)

