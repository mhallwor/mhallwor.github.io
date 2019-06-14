## ------------------------------------------------------------------------
library(raster)
library(sp)
library(gstat)
library(spstat)

## ------------------------------------------------------------------------
load("../Spatial_Layers/spproute.rda")

## ----echo = FALSE--------------------------------------------------------
States <- readRDS("GADM_2.8_USA_adm1.rds")
cols <- sp::bpy.colors(100)
breaks <- seq(0,100,1) 
a <- cut(sppStateRoute$SpeciesDetected,breaks)
raster::plot(States[States$NAME_1=="Arizona",])
raster::plot(States,add = TRUE, col = "gray88")
raster::plot(sppStateRoute,col = cols[a],pch = 19,cex =as.numeric(a)/30,add = TRUE)
raster::plot(States,add = TRUE)
legend(x = raster::extent(sppStateRoute)[2]+1.5,
       y=raster::extent(sppStateRoute)[4],
       legend = c(1,5,10,20,40,50,100),
       pch = 19,
       title = "Species",
       col = cols[c(1,5,10,20,40,50,100)],
       pt.cex = c(1,5,10,20,40,50,100)/30,
       bty = "n")

## ------------------------------------------------------------------------
# Spatial grid over the extent of sppStateRoute
# approximately 5000 random points
set.seed(12345)
samplegrid <- raster::raster(sppStateRoute,res = c(0.025,0.025))

# define CRS
raster::crs(samplegrid) <- raster::crs(sppStateRoute) <- sp::CRS("+init=epsg:4326")

## ------------------------------------------------------------------------
idw.model <- gstat(formula=sppStateRoute$SpeciesDetected~1, 
                   locations=sppStateRoute)

idw.spp <- raster::interpolate(samplegrid, idw.model)

## ----echo = FALSE--------------------------------------------------------
idw.spp

## ------------------------------------------------------------------------
idw.spp.az <- raster::mask(idw.spp, States[States$NAME_1=="Arizona",])

raster::plot(idw.spp.az)

## ------------------------------------------------------------------------
# create variogram 
vario <- variogram(sppStateRoute$SpeciesDetected~1, sppStateRoute)
vario.fit <- fit.variogram(vario,
                           vgm(psill=(max(vario$gamma)-min(vario$gamma)),
                               model="Exp", nugget=1))

predict.model <- gstat(g=NULL,
                      formula = sppStateRoute$SpeciesDetected~1,
                      locations = sppStateRoute, 
                      model=vario.fit)

sgrid <- as(samplegrid,"SpatialGrid")

k.spec <- predict(predict.model,sgrid)

vline <- variogramLine(m,maxdist = 300)
plot(vario$gamma ~ vario$dist,pch = 19)
points(vline[,2]~vline[,1],type = "l")

## ----echo = FALSE--------------------------------------------------------
par(bty ="l")
plot(vario$gamma ~ vario$dist,pch = 19,las =1,ylab = "gamma",xlab = "distance")

## ------------------------------------------------------------------------

### Inverse distance weighting 

## ------------------------------------------------------------------------
load("../Spatial_Layers/spproute.rda")
raster::plot(sppStateRoute)

