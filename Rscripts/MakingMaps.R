## ------------------------------------------------------------------------
library(raster)
library(leaflet)

## ------------------------------------------------------------------------
# Read the State boundaries
States <- raster::getData("GADM",country = "United States", level = 1)

# Subset to include only New Hampshire
NH <- States[States$NAME_1 == "New Hampshire",]

# This call makes the map
mapNH <- leaflet(data = NH) %>%  # inital map
      addTiles() %>%            # add a baselayer
   addProviderTiles("Esri.WorldImagery", group = "Aerial") %>% # specific baselayer with name
   addProviderTiles("OpenTopoMap", group = "Topography")%>% # specific baselayer with name
   addPolygons(., stroke = TRUE, weight = 1, color = "black", # add New Hampshire polygon
      highlightOptions = highlightOptions(color = "white", weight = 2, # highlight when over
      bringToFront = TRUE)) %>%
 # Layers control 
            addLayersControl(      # give user control of basemap 
              baseGroups = c("Aerial", "Topography"), # these groups are labelled above
              options = layersControlOptions(collapsed = TRUE)) # collapse options

mapNH %>% addMiniMap() # add map inset to plot

