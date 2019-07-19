## ----global_options, include=FALSE---------------------------------------
knitr::opts_chunk$set(warning=FALSE, message=FALSE)


## ------------------------------------------------------------------------
library(sf)
library(tidyverse)

ju_sfg <- st_point(c(-134.4333, 58.3059)) #Juneau
an_sfg <- st_point(c(-149.8631, 61.2174)) #Anchorage
fa_sfg <- st_point(c(-147.7767, 64.8354)) #Fairbanks
nm_sfg <- st_point(c(-165.4064, 64.5011)) #Nome



## ------------------------------------------------------------------------
st_coordinates(ju_sfg)


## ------------------------------------------------------------------------
## Create MULTIPOINT object
ak_sfg <- st_multipoint(rbind(c(-134.4333, 58.3059), 
                              c(-149.8631, 61.2174),
                              c(-147.7767, 64.8354),
                              c(-165.4064, 64.5011)))


## ----eval = FALSE--------------------------------------------------------
## # Create LINESTRING object
## ak_sfg <- st_linestring(rbind(c(-134.4333, 58.3059),
##                               c(-149.8631, 61.2174),
##                               c(-147.7767, 64.8354),
##                               c(-165.4064, 64.5011)))


## ------------------------------------------------------------------------
cities_sfc <- st_sfc(ju_sfg, an_sfg, fa_sfg, nm_sfg, crs = 4326)
cities_sfc


## ------------------------------------------------------------------------
st_crs(cities_sfc)


## ------------------------------------------------------------------------
plot(cities_sfc)


## ------------------------------------------------------------------------
# Create data.frame with attributes
cities_df <- data.frame(Name = c("Juneau", "Anchorage", "Fairbanks", "Nome"),
                        Population = c(31276, 291826, 3598, 31535),
                        Elevation = c(17, 31, 6, 136))

# Combine data.frame and spatial data
cities_sf <- st_sf(cities_df, geometry = cities_sfc)



## ------------------------------------------------------------------------
cities_sf


## ------------------------------------------------------------------------
class(cities_sf)


## ------------------------------------------------------------------------
str(cities_sf)


## ------------------------------------------------------------------------
ak <- raster::shapefile("../Spatial_Layers/ak.shp")
class(ak)


## ------------------------------------------------------------------------
### Covert from SpatialPolygonsDataframe to sf
ak_sf <- st_as_sf(ak)


### Set CRS to WGS84
ak_sf <- st_transform(ak_sf, crs = 4326)

### View object
ak_sf


## ---- eval = FALSE-------------------------------------------------------
## install.packages("ggplot2")


## ------------------------------------------------------------------------
library(ggplot2)
ggplot() +
  geom_sf(data = ak_sf) +     # Alaska border polygon
  geom_sf(data = cities_sf, color = "red", size = 3)   # Cities


## ------------------------------------------------------------------------
ggplot() +
  geom_sf(data = ak_sf) +
  geom_sf(data = cities_sf, color = "red", size = 3) + 
  theme_minimal()


## ------------------------------------------------------------------------
ggplot() +
  geom_sf(data = ak_sf) +
  geom_sf(data = cities_sf, color = "red",
          aes(size = Population), 
          show.legend = "point") + 
  theme_minimal()


## ------------------------------------------------------------------------
cities_sf <- mutate(cities_sf, 
                    x = purrr::map_dbl(geometry, 1), 
                    y = purrr::map_dbl(geometry, 2))

ggplot() +
  geom_sf(data = ak_sf) +
  geom_sf(data = cities_sf, color = "red",
          aes(size = Population), 
          show.legend = "point") + 
  geom_text(data = cities_sf, 
            aes(x = x, y = y, 
                label = Name), hjust = 1.2) +
  theme_minimal() +
  theme(axis.title = element_blank())

