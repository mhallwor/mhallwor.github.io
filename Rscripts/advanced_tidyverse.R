## ----global_options, include=FALSE---------------------------------------
knitr::opts_chunk$set(warning=FALSE, message=FALSE)


## ----message = FALSE, error = FALSE, warning = FALSE---------------------
library(sf)
library(tidyverse)

### Load data.frame containing the BBS spatial information
load("../Spatial_Layers/bbs_xy.rda")

### Note the columns containing lat/long for each route
head(bbs_xy)


## ----message=FALSE-------------------------------------------------------
### Convert to `sf`
bbs_xy_sf <- st_as_sf(bbs_xy, coords = c("Longitude", "Latitude"), crs = 4326)

head(bbs_xy_sf)


## ------------------------------------------------------------------------
## Alaska's statenum == 3
ak_bbs_sf1 <- dplyr::filter(bbs_xy_sf, statenum == 3)


## ------------------------------------------------------------------------
ak <- raster::shapefile("../Spatial_Layers/ak.shp")

ak_sf <- st_as_sf(ak) %>%
  st_transform(crs = 4326)

ggplot() + 
  geom_sf(data = ak_sf) +
  geom_sf(data = ak_bbs_sf1) +
  theme_minimal()


## ------------------------------------------------------------------------
ak_bbs_sf2 <- st_intersection(x = bbs_xy_sf, y = ak_sf)

ggplot() + 
  geom_sf(data = ak_sf) +
  geom_sf(data = ak_bbs_sf2) +
  theme_minimal() 


## ------------------------------------------------------------------------

shared <- filter(ak_bbs_sf2, routeID %in% ak_bbs_sf1$routeID)

ggplot() + 
  geom_sf(data = ak_sf) +
  geom_sf(data = ak_bbs_sf1, color = "red") +
  geom_sf(data = shared) +
  theme_minimal()


## ------------------------------------------------------------------------
ak_sf2 <- st_transform(ak_sf, crs = 2964)

ak_buffer <- st_buffer(ak_sf2, dist = 25000) 

ggplot() +
  geom_sf(data = ak_buffer, color = "blue") +
  geom_sf(data = ak_sf2)



## ------------------------------------------------------------------------
ak_buffer <- st_transform(ak_buffer, crs = 4326)
ak_bbs_sf <- st_intersection(bbs_xy_sf, ak_buffer)

ggplot() +
  geom_sf(data = ak_sf) +
  geom_sf(data = ak_buffer, color = "blue") +
  geom_sf(data = ak_bbs_sf)


## ------------------------------------------------------------------------
load("../Spatial_Layers/bbs_counts.rda")
head(bbs_counts)


## ------------------------------------------------------------------------
ak_counts_sf <- left_join(ak_bbs_sf, bbs_counts)

## Look at new object
head(ak_counts_sf)

## Map new object just to make sure it only has the routes we want
ggplot() +
  geom_sf(data = ak_sf) +
  geom_sf(data = ak_counts_sf)


## ------------------------------------------------------------------------
ak_counts_sf <- mutate(ak_counts_sf, 
                       Species = case_when(aou == 4860 ~ "Common raven",
                                           aou == 5090 ~ "Rusty blackbird", 
                                           aou == 7410 ~ "Chestnut-backed chickadee"))


## ------------------------------------------------------------------------
mean_counts_sf <- ak_counts_sf %>%
                group_by(Species, routeID) %>%  # Group by species & route 
                 summarise(count = mean(speciestotal)) %>% # Mean count for all years
                  ungroup() # Always ungroup!!!!


head(mean_counts_sf)


## ----out.width="100%"----------------------------------------------------
## Remove routes that didn't count any of the three species
## These routes will have NA for the count fields
## !is.na() returns only rows that ARE NOT NA
mean_counts_sf <- dplyr::filter(mean_counts_sf, !is.na(Species))

## Recreate AK cities SF object
# Create data.frame with attributes
cities_df <- data.frame(Name = c("Juneau", "Anchorage", "Fairbanks", "Nome"),
                        Population = c(31276, 291826, 3598, 31535),
                        Elevation = c(17, 31, 6, 136))

ju_sfg <- st_point(c(-134.4333, 58.3059)) #Juneau
an_sfg <- st_point(c(-149.8631, 61.2174)) #Anchorage
fa_sfg <- st_point(c(-147.7767, 64.8354)) #Fairbanks
nm_sfg <- st_point(c(-165.4064, 64.5011)) #Nome

cities_sf <- st_sfc(ju_sfg, an_sfg, fa_sfg, nm_sfg, crs = 4326) %>%
               st_sf(cities_df, geometry = .)

ggplot() +
  geom_sf(data = ak_sf) +
  geom_sf(data = cities_sf, color = "red", size = 3) +
  geom_sf(data = mean_counts_sf, aes(size = count),
          show.legend = "point") +
  facet_wrap(~Species) +
  theme_minimal()


## ------------------------------------------------------------------------
download.file(url = "https://www.pwrc.usgs.gov/bba/view/download_map_files/bcr_shp.zip",
              destfile = "../Spatial_Layers/bcr.zip")

unzip(zipfile = "../Spatial_Layers/bcr.zip",
      exdir = "../Spatial_Layers/bcr")

bcr <- raster::shapefile("../Spatial_Layers/bcr/BCR.shp")


## ------------------------------------------------------------------------
### Covert the BCR shapefile to class `sf`
bcr_sf <- st_as_sf(bcr) 


## ----error = TRUE--------------------------------------------------------
ak_bcr_sf <- st_intersection(ak_sf, bcr_sf)


## ------------------------------------------------------------------------
ak_bcr_sf <- st_transform(bcr_sf, crs = st_crs(ak_sf)) %>%
  st_intersection(., ak_sf)


## ------------------------------------------------------------------------
ggplot() + 
  geom_sf(data = ak_bcr_sf, aes(fill = BCRName)) +
  geom_sf(data = cities_sf, shape = 18, color = "red", size = 4) +
  theme_minimal()


## ------------------------------------------------------------------------
st_area(ak_bcr_sf)/100000


## ------------------------------------------------------------------------
ak_bcr_sf <- dplyr::mutate(ak_bcr_sf, Area = st_area(geometry)/100000)
ak_bcr_sf


## ----out.width = "100%"--------------------------------------------------
ggplot() +
  geom_sf(data = ak_sf) +
  geom_sf(data = ak_bcr_sf, aes(fill = BCRName), 
          show.legend = FALSE) +
  geom_sf(data = cities_sf, color = "red", shape = 18, size = 4) +
  geom_sf(data = mean_counts_sf, aes(size = count),
          show.legend = FALSE) +
  facet_wrap(~Species) +
  theme_minimal()

