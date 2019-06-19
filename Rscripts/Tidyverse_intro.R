## ----global_options, include=FALSE---------------------------------------
knitr::opts_chunk$set(warning=FALSE, message=FALSE)


## ------------------------------------------------------------------------
library(sf)

tu_sfg <- st_point(c(-110.9265, 32.2217)) #Tucson
ph_sfg <- st_point(c(-112.0740, 33.4484)) #Phoenix
fl_sfg <- st_point(c(-111.6513, 35.1983)) #Flagstaff



## ------------------------------------------------------------------------
st_coordinates(tu_sfg)


## ------------------------------------------------------------------------
## Create MULTIPOINT object
az_sfg <- st_multipoint(rbind(c(-110.9265, 32.2217), 
                              c(-112.0740, 33.4484),
                              c(-111.6513, 35.1983)))


## ----eval = FALSE--------------------------------------------------------
## # Create LINESTRING object
## az_sfg <- st_linestring(rbind(c(-110.9265, 32.2217),
##                               c(-112.0740, 33.4484),
##                               c(-111.6513, 35.1983)))


## ------------------------------------------------------------------------
cities_sfc <- st_sfc(tu_sfg, ph_sfg, fl_sfg, crs = 4326)
cities_sfc


## ------------------------------------------------------------------------
st_crs(cities_sfc)


## ------------------------------------------------------------------------
plot(cities_sfc)


## ------------------------------------------------------------------------
# Create data.frame with attributes
cities_df <- data.frame(Name = c("Tucson", "Phoenix", "Flagstaff"),
                        Population = c(520116, 1445632, 65870),
                        Elevation = c(2389, 1086, 6910))

# Combine data.frame and spatial data
cities_sf <- st_sf(cities_df, geometry = cities_sfc)



## ------------------------------------------------------------------------
cities_sf


## ------------------------------------------------------------------------
class(cities_sf)


## ------------------------------------------------------------------------
str(cities_sf)


## ------------------------------------------------------------------------
library(maps)
us_states <- map("state", plot = FALSE, fill = TRUE)
str(us_states)


## ----error = TRUE--------------------------------------------------------
library(tidyverse)

az_poly <- filter(us_states, names == "arizona")


## ------------------------------------------------------------------------
states_sf <- st_as_sf(us_states)


## ------------------------------------------------------------------------
names(states_sf)


## ------------------------------------------------------------------------
az_sf <- filter(states_sf, ID == "arizona")
az_sf


## ---- eval = FALSE-------------------------------------------------------
## devtools::install_github("tidyverse/rlang", build_vignettes = TRUE)
## devtools::install_github("tidyverse/ggplot2")


## ------------------------------------------------------------------------
ggplot() +
  geom_sf(data = az_sf) +     # Arizona border polygon
  geom_sf(data = cities_sf)   # Cities


## ------------------------------------------------------------------------
ggplot() +
  geom_sf(data = az_sf) +
  geom_sf(data = cities_sf) + 
  theme_minimal()


## ------------------------------------------------------------------------
ggplot() +
  geom_sf(data = az_sf) +
  geom_sf(data = cities_sf, 
          aes(size = Population), 
          show.legend = "point") + 
  theme_minimal()


## ------------------------------------------------------------------------
cities_sf <- mutate(cities_sf, 
                    x = purrr::map_dbl(geometry, 1), 
                    y = purrr::map_dbl(geometry, 2))

ggplot() +
  geom_sf(data = az_sf) +
  geom_sf(data = cities_sf, 
          aes(size = Population), 
          show.legend = "point") + 
  geom_text(data = cities_sf, 
            aes(x = x, y = y, 
                label = Name), hjust = 1.2) +
  theme_minimal() +
  theme(axis.title = element_blank())

