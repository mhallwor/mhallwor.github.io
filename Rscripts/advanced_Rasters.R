## ----echo = FALSE--------------------------------------------------------
knitr::opts_chunk$set(fig.width=10)


## ----load-raster, message = FALSE, error = FALSE, warning = FALSE--------
# load library
library(raster)
library(lwgeom)
library(maptools)
library(rgdal)
library(gdalUtils)


## ---- message = FALSE, warning = FALSE-----------------------------------
rgdal::GDALinfo("../Spatial_Layers/MOD_NDVI_M_2018-01-01_rgb_3600x1800.FLOAT.TIFF")


## ----eval = FALSE--------------------------------------------------------
## raster::rasterOptions(tmpdir = "path/to/drive/with/space")


## ----echo = FALSE, fig.width = 10----------------------------------------
data(wrld_simpl, package = "maptools")
MODIStiles <- raster::shapefile("../Spatial_Layers/modis_sinusoidal_grid_world.shp")
wrld_proj <- sp::spTransform(wrld_simpl,sp::CRS(MODIStiles@proj4string@projargs))

raster::plot(wrld_proj,col = "gray",border = "gray")
raster::plot(MODIStiles,add = TRUE, border = "gray60")
mtext(side = 3, text = "h", line = 0)
mtext(side = 2, text = "v",las = 1)
hlab <- rgeos::gCentroid(MODIStiles[MODIStiles$v ==0,],byid = TRUE)
vlab <- rgeos::gCentroid(MODIStiles[MODIStiles$h ==0,],byid = TRUE)
text(x = hlab@coords[,1], y = rep(hlab@coords[1,2],36),(0:35),cex = 0.75)
text(x = rep(hlab@coords[1,1],17), y = vlab@coords[,2],(17:0),cex = 0.75)


## ------------------------------------------------------------------------
# Read in MODIS tile grid
MODIStiles <- raster::shapefile("../Spatial_Layers/modis_sinusoidal_grid_world.shp")


## ------------------------------------------------------------------------
# Read in states
States <- raster::getData("GADM", country = "United States", level = 1)

# Subset out AZ
AZ <- States[States$NAME_1 == "Arizona",]

# transform AZ to MODIS
AZ_sinsu <- sp::spTransform(AZ, sp::CRS(MODIStiles@proj4string@projargs))


## ------------------------------------------------------------------------
identicalCRS(x = MODIStiles, y= AZ_sinsu)


## ------------------------------------------------------------------------
sp::over(AZ_sinsu,MODIStiles,returnList = TRUE)


## ---- error = TRUE, message = FALSE, results = "hide"--------------------
#MODIS files to download
MODISfiles <- read.csv("../Spatial_Layers/MODIStoget.csv")

# To save space on our hard drive and save time we'll only get year 2000 & 2015
urls_to_get <- paste0("https://ladsweb.modaps.eosdis.nasa.gov",MODISfiles[c(1:2,35:36),2])

# Where to save the files
save_hdf_file <- urls_to_get

# replace url
save_hdf_file <- gsub(x = save_hdf_file,
                      pattern = "https://ladsweb.modaps.eosdis.nasa.gov/archive/allData/6/",
                      replacement = "")
# replace / with .
save_hdf_file <- gsub(x = save_hdf_file,
                     pattern = "[/]",
                     replacement = ".")

# add "../Spatial_Layers/"
save_hdf_file <- paste0("../Spatial_Layers/",save_hdf_file)

# Download using download.file #

mapply(function(x,y){
       download.file(url = x,
                     destfile = y,
                     cacheOK = TRUE,
                     mode = "wb",
                     extra = list(getOption("download.file.extra")))},
       x = urls_to_get,
       y = save_hdf_file)


## ---- eval = FALSE,error = TRUE------------------------------------------
## h <- raster::raster(save_hdf_file[1])


## ------------------------------------------------------------------------
# Extract the names of the datasets within the compressed hdf file
# Band 1 = Red
# Band 2 = NIR
subsets <- gdalUtils::get_subdatasets(save_hdf_file[1])


## ----eval = FALSE--------------------------------------------------------
## #Covert subset of interest into geoTIFF
## # red band
## gdalUtils::gdal_translate(src_dataset = subsets[2],
##                           dst_dataset = "../Spatial_Layers/band_1_2000_h08v05.tiff")
## # nir band
## gdalUtils::gdal_translate(src_dataset = subsets[3],
##                           dst_dataset = "../Spatial_Layers/band_2_2000_h08v05.tiff")


## ----eval = FALSE, echo = FALSE------------------------------------------
## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
## # THE FOLLOWING CODE IS FOR WINDOWS SYSTEMS. THE WORKSHOP MATERIALS
## # ARE CREATED USING LINUX SYSTEMS
## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


## ----eval = FALSE--------------------------------------------------------
## # List the .hdf files
## hdf_files <- list.files(path = "../Spatial_Layers/",
##                         pattern = "*.hdf",
##                         full.names = TRUE)
## 
## # generate names of output files
## redband_files <- gsub(x = hdf_files,
##                   pattern = ".hdf",
##                   replacement = "_redband.tiff")
## 
## # generate names of output files
## nirband_files <- gsub(x = hdf_files,
##                   pattern = ".hdf",
##                   replacement = "_nirband.tiff")
## 
## # note the use of gsub to rename output files
## a <- Sys.time()
## # Convert all hdf to geoTiff
## mapply(a = hdf_files,
##        y = redband_files,
##        z = nirband_files,
##        FUN = function(a,y,z){
##        b <- get_subdatasets(a)
##        gdal_translate(b[2], dst_dataset = y)
##        gdal_translate(b[3], dst_dataset = z)
##        })
## Sys.time()-a


## ----echo = FALSE--------------------------------------------------------
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# THE FOLLOWING CODE IS FOR LINUX SYSTEMS. THE WORKSHOP MATERIALS
# ARE CREATED USING LINUX SYSTEMS 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

## ------------------------------------------------------------------------
# List the .hdf files 
hdf_files <- list.files(path = "../Spatial_Layers/", 
                        pattern = "*.hdf", 
                        full.names = TRUE)

subsets <- lapply(hdf_files, get_subdatasets)

## ----echo = FALSE--------------------------------------------------------
str(subsets)

## ------------------------------------------------------------------------
# Create empty lists to fill with rasters. This is used to stay consistent with the 
# windows workflow.

h08_red_rasters <- h08_nir_rasters <- h09_red_rasters <- h09_nir_rasters <- vector("list",2)

# Use the subsets list to generate rasters
h08_red_rasters[[1]] <- raster(subsets[[1]][2]) #second band of first element 
h08_red_rasters[[2]] <- raster(subsets[[3]][2]) #second band of third element

h08_nir_rasters[[1]] <- raster(subsets[[1]][3]) #second band of first element 
h08_nir_rasters[[2]] <- raster(subsets[[3]][3]) #second band of third element

h09_red_rasters[[1]] <- raster(subsets[[2]][2]) #second band of first element 
h09_red_rasters[[2]] <- raster(subsets[[4]][2]) #second band of third element

h09_nir_rasters[[1]] <- raster(subsets[[2]][3]) #second band of first element 
h09_nir_rasters[[2]] <- raster(subsets[[4]][3]) #second band of third element


## ----echo = FALSE--------------------------------------------------------
######################################################## 
# THE FOLLOWING CODE SHOULD BE RUN IF YOU'RE USING A
# A WINDOWS MACHINE
########################################################

## ----eval = FALSE--------------------------------------------------------
## # Note use of grep
## h08_red_rasters <- lapply(redband_files[grep(x=redband_files,"h08")],raster)
## h08_nir_rasters <- lapply(nirband_files[grep(x=nirband_files,"h08")],raster)
## 
## h09_red_rasters <- lapply(redband_files[grep(x=redband_files,"h09")],raster)
## h09_nir_rasters <- lapply(nirband_files[grep(x=nirband_files,"h09")],raster)


## ------------------------------------------------------------------------
h08_rasters <- raster::stack(c(h08_red_rasters,h08_nir_rasters))
h09_rasters <- raster::stack(c(h09_red_rasters,h09_nir_rasters))


## ----echo = TRUE---------------------------------------------------------
h08_rasters


## ------------------------------------------------------------------------
# Calculate NDVI for each year
h08_NDVI_2000 <- (h08_rasters[[3]]-h08_rasters[[1]])/(h08_rasters[[3]]+h08_rasters[[1]])
h08_NDVI_2017 <- (h08_rasters[[4]]-h08_rasters[[2]])/(h08_rasters[[4]]+h08_rasters[[2]])

# Calculate NDVI for each year
h09_NDVI_2000 <- (h09_rasters[[3]]-h09_rasters[[1]])/(h09_rasters[[3]]+h09_rasters[[1]])
h09_NDVI_2017 <- (h09_rasters[[4]]-h09_rasters[[2]])/(h09_rasters[[4]]+h09_rasters[[2]])


## ----echo = FALSE--------------------------------------------------------
h08_NDVI_2000
plot(h08_NDVI_2000, zlim = c(-1,1))


## ------------------------------------------------------------------------
# if you haven't already - this is a good
# place to set the tmpdir to store
# large rasters

# rasterOptions(tmpdir = "path/to/temprasters")
a <- Sys.time()
NDVI_2000 <- mosaic(h08_NDVI_2000,
                    h09_NDVI_2000,
                    fun = min,
                    na.rm = TRUE,
                    filename = "../Spatial_Layers/ndvi_2000.tif",
                    overwrite = TRUE)

NDVI_2017 <- mosaic(h08_NDVI_2017,
                    h09_NDVI_2017,
                    fun = min,
                    na.rm = TRUE,
                    filename = "../Spatial_Layers/ndvi_2017.tif",
                    overwrite = TRUE)
Sys.time()-a


## ------------------------------------------------------------------------
NDVI_2000[NDVI_2000 > 1] <- NA
NDVI_2000[NDVI_2000 < -1] <- NA

NDVI_2017[NDVI_2017 > 1] <- NA
NDVI_2017[NDVI_2017 < -1] <- NA


## ----echo = FALSE, fig.width = 10----------------------------------------
NDVIs <- stack(NDVI_2000,NDVI_2017)

par(mfrow = c(1,2),mai = c(0.2,0.2,0.2,0.2),bty="n")
yr <- c(2000,2017)
for(i in 1:2){
plot(NDVIs[[i]],axes=FALSE,legend = FALSE)
mtext(side=3,yr[i],line = -8)
plot(AZ_sinsu, add = TRUE)
}


## ------------------------------------------------------------------------
# NDVI in 2017 - NDVI in 2000
diff_ndvi <- NDVI_2017-NDVI_2000

## ----echo = FALSE--------------------------------------------------------
diff_ndvi
plot(diff_ndvi, zlim = c(-1,1))
hist(diff_ndvi, yaxt = "n",las=1,main = "Difference in NDVI\n 2000-2017",xlab = "Difference in NDVI",col = "gray88",border = "white")


## ------------------------------------------------------------------------
# from -2 to -0.025 take value 1
# from -0.05 to 0.025 take value 0
# from 0.05 to 2 take value 2 
reclassMatrix <- matrix(c(-2,-0.025,1,
                          -0.025,0.025,0,
                          0.025,2,2),3,3,byrow = TRUE)

# reclassify diff_tc to values ranging from 0-2
ndvi_change <- reclassify(diff_ndvi, rcl = reclassMatrix)

## ----echo = FALSE--------------------------------------------------------
plot(ndvi_change, col = colorRampPalette(c("wheat3","springgreen4"))(3))


## ------------------------------------------------------------------------
ndvi_brick <- brick(c(ndvi_change,ndvi_change,ndvi_change))


## ------------------------------------------------------------------------
rgb_vals <- col2rgb(colorRampPalette(c("wheat3","springgreen4"))(3))

## ----echo = FALSE--------------------------------------------------------
rgb_vals


## ------------------------------------------------------------------------
# Make our reclassify matrix
# note I transposed the rgb_vals

reclassRGB <- cbind(c(-2.5,-0.05,0.05),#from
                    c(-0.05,0.05,2.5),#to
                    t(rgb_vals))#transposed rgb values

ndvi_brick[[1]] <- reclassify(ndvi_brick[[1]],rcl=reclassRGB[,c(1:2,3)])
ndvi_brick[[2]] <- reclassify(ndvi_brick[[2]],rcl=reclassRGB[,c(1:2,4)])
ndvi_brick[[3]] <- reclassify(ndvi_brick[[3]],rcl=reclassRGB[,c(1:2,5)])


## ------------------------------------------------------------------------
plotRGB(ndvi_brick)


## ----echo = FALSE, results="hide",message = FALSE,warning = FALSE--------
# DELETE FILES SO THEY DON'T MAKE IT TO GITHUB
remove(list=ls())
nd <- list.files("../Spatial_Layers",full.names = TRUE)[grep(x=list.files("../Spatial_Layers"),pattern = "ndvi*")]
bd <- list.files("../Spatial_Layers/",full.names = TRUE)[grep(x=list.files("../Spatial_Layers"),pattern = "h08v05")]
d <- list.files("../Spatial_Layers/" ,full.names = TRUE)[grep(x=list.files("../Spatial_Layers"),pattern = "h09v05")]

file.remove(c(nd,bd,d))

