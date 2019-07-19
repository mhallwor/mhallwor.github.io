## ----echo = FALSE--------------------------------------------------------
knitr::opts_chunk$set(fig.width=10)


## ----message = FALSE, warning = FALSE------------------------------------
library(raster)
library(sp)
library(gstat)
library(spatstat)


## ------------------------------------------------------------------------
load("../Spatial_Layers/spproute.rda")


## ----echo = FALSE--------------------------------------------------------
States <- readRDS("../Spatial_Layers/GADM_2.8_USA_adm1.rds")
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
# set.seed() makes sure the random points are the same each time
# increases reproducability 

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

par(bty="n",mar = c(0,0,0,0))
raster::plot(idw.spp.az,
             axes = FALSE,
             legend.args = list("Species\nRichness"))
plot(States, add = TRUE)


## ------------------------------------------------------------------------
# remove duplicate locations because otherwise Kriging returns NA
sppStateRoute <- sppStateRoute[-sp::zerodist(sppStateRoute)[,1],]

# create variogram 
vario <- variogram(sppStateRoute$SpeciesDetected~1, sppStateRoute)


## ---- echo = FALSE-------------------------------------------------------
vario.fit <- fit.variogram(vario,
                           vgm(psill=250, # approx asymptote
                               range = 150,
                               model="Exp", 
                               nugget=50))
vline <- variogramLine(vario.fit,maxdist = 300)


## ---- echo = FALSE-------------------------------------------------------
plot(vario$gamma ~ vario$dist,pch = 19,ylim = c(0,300),las = 1, ylab = "gamma",xlab = "Lag distance")
points(vline[,2]~vline[,1],type = "l")


## ------------------------------------------------------------------------
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


## ----eval = FALSE, comment=""--------------------------------------------
Covariance matrix singular at location [-114.543,36.7882,0]: skipping...


## ---- echo = FALSE-------------------------------------------------------
krig.spp.az <- raster::mask(SpeciesRichness, States[States$NAME_1=="Arizona",])
plot(krig.spp.az,las = 1,legend.args=list("Species\nRichness"))
plot(States,add = TRUE)

