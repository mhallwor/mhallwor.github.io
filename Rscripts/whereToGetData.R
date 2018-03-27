## ----echo = FALSE, fig.width = 10, fig.height = 5------------------------
par(mar = c(0,0,0,0))
raster::plotRGB(raster::brick("../Spatial_Layers/BlueMarbleNG-TB_2004-09-01_rgb_3600x1800.TIFF"),
                colNA = "black")


