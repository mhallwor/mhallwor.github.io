## ----echo = FALSE--------------------------------------------------------
knitr::opts_chunk$set(fig.width=10)


## ----load-packages, warning = FALSE, error = FALSE, message = FALSE------
library(raster)
library(velox)
library(sp)
library(rgeos)


## ------------------------------------------------------------------------
# read in DEM of HBEF
DEM <- raster::raster("../Spatial_Layers/hb10mdem.txt")


## ------------------------------------------------------------------------
SurveyLocs <- raster::shapefile("../Spatial_Layers/hbef_valleywideplots.shp")


## ----echo = FALSE--------------------------------------------------------
SurveyLocs


## ------------------------------------------------------------------------
crs(SurveyLocs)
crs(DEM)


## ------------------------------------------------------------------------
# Transform points to match CRS of the DEM
SurveyLocs_proj <- sp::spTransform(x = SurveyLocs,
                                   CRSobj = crs(DEM))


## ------------------------------------------------------------------------
# Extract elevation to SpatialPoints
surveyElev <- raster::extract(x = DEM,
                              y = SurveyLocs_proj)


## ----echo = FALSE--------------------------------------------------------
str(surveyElev)


## ------------------------------------------------------------------------
SurveyLocs_proj$Elev_m <- raster::extract(x = DEM,
                                          y = SurveyLocs_proj)


## ----echo = FALSE--------------------------------------------------------
SurveyLocs_proj

## ----echo = FALSE--------------------------------------------------------
hist(surveyElev,col = "gray88",main = "",breaks = 15, las = 1, xlab = "Elevation (m)")


## ------------------------------------------------------------------------
# Read in landcover data
LandCover <- raster::raster("../Spatial_Layers/MCD12C1_T1_2011-01-01_rgb_3600x1800.TIFF")

## ----echo = FALSE--------------------------------------------------------
LandCover


## ------------------------------------------------------------------------
States <- raster::getData("GADM", country = "United States", level = 1)


## ------------------------------------------------------------------------
AK <- States[States$NAME_1=="Alaska",]


## ---- warning = FALSE,echo = FALSE---------------------------------------
AK


## ------------------------------------------------------------------------
# Extract using the raster package 

# x = raster layer
# y = SpatialLayer

a <- Sys.time()
AK_lc <- extract(x = LandCover,
                 y = AK)
Sys.time()-a

# Extract using velox 
LandCover_velox <- velox::velox(LandCover)

b <- Sys.time()
AK_lc_velox <- LandCover_velox$extract(AK)
Sys.time() - b


## ---- echo = FALSE-------------------------------------------------------
# Get the structure of the extracted data
str(AK_lc)


## ------------------------------------------------------------------------
table(AK_lc)


## ---- echo = FALSE, fig.width = 8, fig.height = 6------------------------
lower48 <- States[!(States$NAME_1 %in% c("Hawaii")),]
plot(lower48, xlim = c(-179.15,-50), ylim=c(20,80))
plot(LandCover, add = TRUE, ext = raster::extent(c(-179.15,-50,20,80)))
plot(lower48, add = TRUE)
plot(AK,add = TRUE,border = "red",lwd = 2)
#par(new = TRUE, fig = c(0.5,0.9,0.1,0.9), mar = c(1,1,1,1))
#plot(AK,xlim = c(-179.15,-120),ylim = c(51,73))
#plot(LandCover, add = TRUE, ext = raster::extent(c(-179.15,-140,51,73)))
#plot(AK, add = TRUE)


## ---- eval = FALSE, echo = FALSE, fig.width = 8, fig.height = 6----------
## lower48 <- States[!(States$NAME_1 %in% c("Hawaii","Alaska")),]
## plot(lower48)
## plot(LandCover, add = TRUE, ext = raster::extent(lower48))
## plot(lower48, add = TRUE)
## plot(AZ,add = TRUE,border = "red",lwd = 2)
## par(new = TRUE, fig = c(0.5,0.9,0.1,0.9), mar = c(1,1,1,1))
## plot(AZ)
## plot(LandCover, add = TRUE, ext = raster::extent(AZ))
## plot(AZ, add = TRUE)


## ------------------------------------------------------------------------
# sort the unique values in LandCover
z <- sort(unique(raster::values(LandCover)))


## ----echo = FALSE--------------------------------------------------------
z


## ------------------------------------------------------------------------
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


## ------------------------------------------------------------------------
summaryValues <- lapply(AK_lc,FUN = summarizeLC,LC_classes = z)


## ---- echo = FALSE-------------------------------------------------------
# Make a vector of all landcover types possible in the data set
LC_types <- c("Evergreen Needleleaf forest","Evergreen Broadleaf forest","Deciduous Needleleaf forest","Deciduous Broadleaf forest","Mixed forest","Closed shrublands","Open shrublands","Woody savannas","Savannas","Grasslands","Permanent wetlands","Croplands","Urban and built-up","Cropland/Natural vegetation mosaic","Snow and ice","Barren or sparsely vegetated","Water bodies","Tundra")

# Rerun the summarizeLC function providing the LC_names
summaryValues <- lapply(AK_lc,
                        FUN = summarizeLC,
                        LC_classes = z,
                        LC_names = LC_types[z])

# Name the row "percent"
rownames(summaryValues[[1]]) <- "Percent"

# round to 3 digits and transpose the table 
round(t(summaryValues[[1]]),3)


## ----echo = FALSE--------------------------------------------------------
# Create a SpatialPolygons file with the states of interest
StatesOfInterest <- States[States$NAME_1 %in% c("New Hampshire","West Virginia"),]

# Extract the raster values 
SOI_lc <- LandCover_velox$extract(StatesOfInterest)

lz <- sort(unique(unlist(SOI_lc)))

# Rerun the summarizeLC function providing the LC_names
summaryValues <- lapply(SOI_lc,
                        FUN = summarizeLC,
                        LC_classes = lz,
                        LC_names = LC_types[lz])
# use do.call to combine two or more lists
percentCover <- do.call('rbind',summaryValues)

rownames(percentCover)<-StatesOfInterest$NAME_1

round(t(percentCover),3)

