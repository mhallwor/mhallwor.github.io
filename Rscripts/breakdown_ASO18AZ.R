## ---- echo = FALSE, warning = FALSE, error = FALSE, message = FALSE------
library(raster)

States <- readRDS("../Spatial_Layers/GADM_2.8_USA_adm1.rds") 

st.par <- c("Mississippi","Illinois","California","Colorado",
            "New Mexico","Oregon","Arizona","Washington","Nevada",
            "Hawaii","North Carolina","New Hampshire",
            "Delaware","Texas","New York","Vermont","Ohio","Alabama","Pennsylvania")

par.states <- States[States$NAME_1 %in% st.par,]
st.center <- rgeos::gCentroid(par.states,byid = TRUE)@coords
AK <- cbind(-149.4937,64.2008)
tucson <- cbind(-110.911789,32.253460)
BC <- cbind(-127.6476,53.7267)
ON <- cbind(-85.3232,51.2538)
PR <- cbind(-66.5901,18.2208)

data(wrld_simpl,package = "maptools")
Americas <- wrld_simpl[wrld_simpl$NAME %in% c("Canada","United States","Puerto Rico","Mexico"),]
newproj<- "+proj=lcc +lat_1=20 +lat_2=60 +lat_0=40 +lon_0=-96 +x_0=0 +y_0=0 +ellps=GRS80
+datum=NAD83 +units=m +no_defs +towgs84=0,0,0"

coord <- rbind(st.center,BC,ON,PR,AK)
par.locs <- sp::SpatialPoints(coord)
raster::crs(par.locs)<-sp::CRS("+init=epsg:4326")
par.locs_proj <- sp::spTransform(par.locs,sp::CRS(newproj))
Americas_proj <- sp::spTransform(wrld_simpl[wrld_simpl$REGION==19,],sp::CRS(newproj))
gcLines <- geosphere::gcIntermediate(par.locs,tucson,n=50,addStartEnd=TRUE)
gcLines_sp <- lapply(gcLines,raster::spLines, crs = sp::CRS("+init=epsg:4326"))
gcLines_map <-do.call("rbind",lapply(gcLines_sp,sp::spTransform,sp::CRS(newproj)))

par(mar = c(0,0,0,0))
raster::plot(par.locs_proj,pch = ".")
raster::plot(Americas_proj,add = TRUE,col = "gray",border = "white")
raster::plot(par.locs_proj,add = TRUE, pch = 19)
raster::plot(gcLines_map, add = TRUE)
raster::plot(sp::spTransform(sp::SpatialPoints(tucson,sp::CRS("+init=epsg:4326")),
                             sp::CRS(newproj)),pch = 19, col = "red",add =TRUE)

