## ----global_options, include=FALSE---------------------------------------
knitr::opts_chunk$set(warning=FALSE, message=FALSE)


## ----message = FALSE, error = FALSE, warning = FALSE---------------------
library(sf)
library(tidyverse)
library(maps)

### Load data.frame containing the BBS spatial information
load("../Spatial_Layers/bbs_xy.rda")

### Note the columns containing lat/long for each route
head(bbs_xy)


## ----message=FALSE-------------------------------------------------------
### Convert to `sf`
bbs_xy_sf <- st_as_sf(bbs_xy, coords = c("Longitude", "Latitude"), crs = 4326)

head(bbs_xy_sf)


## ------------------------------------------------------------------------
## Arizona's statenum == 6
az_bbs_sf1 <- dplyr::filter(bbs_xy_sf, statenum == 6)


## ------------------------------------------------------------------------
## AZ polygon
us_states <- map("state", plot = FALSE, fill = TRUE)
az_sf <- st_as_sf(us_states) %>%
           st_transform(crs = 4326) %>%
               filter(ID == "arizona")

ggplot() + 
  geom_sf(data = az_sf) +
  geom_sf(data = az_bbs_sf1) +
  theme_minimal()


## ------------------------------------------------------------------------
az_bbs_sf2 <- st_intersection(x = bbs_xy_sf, y = az_sf)

ggplot() + 
  geom_sf(data = az_sf) +
  geom_sf(data = az_bbs_sf2) +
  theme_minimal()


## ------------------------------------------------------------------------
ggplot() + 
  geom_sf(data = az_sf) +
  geom_sf(data = az_bbs_sf2, aes(color = as.factor(statenum))) +
  theme_minimal()


## ------------------------------------------------------------------------
az_sf2 <- st_transform(az_sf, crs = 26949)

az_buffer <- st_buffer(az_sf2, dist = -40000) %>%
  st_transform(crs = 4326) # Convert CRS back to 4326

ggplot() +
  geom_sf(data = az_sf) +
  geom_sf(data = az_buffer, color = "blue")


## ------------------------------------------------------------------------
az_bbs_sf <- st_intersection(bbs_xy_sf, az_buffer)

ggplot() +
  geom_sf(data = az_sf) +
  geom_sf(data = az_buffer, color = "blue") +
  geom_sf(data = az_bbs_sf)


## ------------------------------------------------------------------------
load("../Spatial_Layers/bbs_counts.rda")
head(bbs_counts)


## ------------------------------------------------------------------------
az_counts_sf <- left_join(az_bbs_sf, bbs_counts)

## Look at new object
head(az_counts_sf)

## Map new object just to make sure it only has the routes we want
ggplot() +
  geom_sf(data = az_sf) +
  geom_sf(data = az_buffer, color = "blue") +
  geom_sf(data = az_counts_sf)


## ------------------------------------------------------------------------
az_counts_sf <- mutate(az_counts_sf, 
                       Species = case_when(aou == 3850 ~ "Greater roadrunner",
                                           aou == 7130 ~ "Cactus wren", 
                                           aou == 7680 ~ "Mountain bluebird"))


## ------------------------------------------------------------------------
mean_counts_sf <- az_counts_sf %>%
                group_by(Species, routeID) %>%  # Group by species & route 
                 summarise(count = mean(speciestotal)) %>% # Mean count for all years
                  ungroup() # Always ungroup!!!!


head(mean_counts_sf)


## ----out.width="100%"----------------------------------------------------
## Remove routes that didn't count any of the three species
## These routes will have NA for the count fields
## !is.na() returns only rows that ARE NOT NA
mean_counts_sf <- dplyr::filter(mean_counts_sf, !is.na(Species))

## Recreate AZ cities SF object
cities_df <- data.frame(Name = c("Tucson", "Phoenix", "Flagstaff"),
                        Population = c(520116, 1445632, 65870),
                        Elevation = c(2389, 1086, 6910))

tu_sfg <- st_point(c(-110.9265, 32.2217)) # Tucson
ph_sfg <- st_point(c(-112.0740, 33.4484)) # Phoenix
fl_sfg <- st_point(c(-111.6513, 35.1983)) # Flagstaff

cities_sf <- st_sfc(tu_sfg, ph_sfg, fl_sfg, crs = 4326) %>%
               st_sf(cities_df, geometry = .)

ggplot() +
  geom_sf(data = az_sf) +
  geom_sf(data = cities_sf, color = "red", shape = 18, size = 4) +
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
az_bcr_sf <- st_intersection(az_sf, bcr_sf)


## ------------------------------------------------------------------------
az_bcr_sf <- st_transform(bcr_sf, crs = st_crs(az_sf)) %>%
  st_intersection(az_sf, .)


## ------------------------------------------------------------------------
ggplot() + 
  geom_sf(data = az_bcr_sf, aes(fill = BCRName)) +
  geom_sf(data = cities_sf, shape = 18, color = "red", size = 4) +
  theme_minimal()


## ------------------------------------------------------------------------
st_area(az_bcr_sf)/10000


## ------------------------------------------------------------------------
az_bcr_sf <- dplyr::mutate(az_bcr_sf, Area = st_area(geometry)/10000)
az_bcr_sf


## ----out.width = "100%"--------------------------------------------------
ggplot() +
  geom_sf(data = az_sf) +
  geom_sf(data = az_bcr_sf, aes(fill = BCRName), 
          show.legend = FALSE) +
  geom_sf(data = cities_sf, color = "red", shape = 18, size = 4) +
  geom_sf(data = mean_counts_sf, aes(size = count),
          show.legend = FALSE) +
  facet_wrap(~Species) +
  theme_minimal()


## ------------------------------------------------------------------------
st_intersects(mean_counts_sf, az_bcr_sf)


## ------------------------------------------------------------------------
mean_counts_sf <- mutate(mean_counts_sf, 
                  BCR.num = purrr::flatten_dbl(st_intersects(mean_counts_sf, az_bcr_sf)),
                  BCR = case_when(BCR.num == 1 ~ "Southern Rockies", 
                                  BCR.num == 2 ~ "Sonoran and Mojave Deserts", 
                                  BCR.num == 3 ~ "Sierra Madre Occidental"))

## Check that each route is indexec by BCR
ggplot() +
  geom_sf(data = az_sf) +
  geom_sf(data = az_bcr_sf, aes(fill = BCRName)) +
  geom_sf(data = cities_sf, color = "red", shape = 18, size = 4) +
  geom_sf(data = mean_counts_sf, aes(color = BCR)) +
  theme_minimal()


## ----out.width="100%"----------------------------------------------------
bcr_abun <- mean_counts_sf %>%
              group_by(Species, BCR) %>%
              summarise(Abundance = mean(count),
                        Stnd.dev = sd(count)) %>%
              ungroup() 

## Reorder BCR levels for figures
bcr_abun$BCR <- factor(bcr_abun$BCR, levels = c("Sonoran and Mojave Deserts", 
                                                "Sierra Madre Occidental", 
                                                "Southern Rockies")) 

ggplot(bcr_abun, aes(x = BCR, y = Abundance, fill = Species)) +
  geom_bar(stat="identity", position = position_dodge(), colour = "black") +
  geom_errorbar(aes(ymin = Abundance - Stnd.dev, 
                    ymax = Abundance + Stnd.dev),
                 width = 0.1,                    # Width of the error bars
                 position=position_dodge(.9)) + 
  theme_minimal()

