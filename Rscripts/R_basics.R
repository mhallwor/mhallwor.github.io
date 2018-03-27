## ----eval = FALSE--------------------------------------------------------
## install.packages(pkgs = c("devtools"), dependencies = TRUE)

## ----eval = FALSE--------------------------------------------------------
## devtools::install_github("Username/repository")

## ---- warning = FALSE, message = FALSE-----------------------------------
library(raster)

## ----eval = FALSE--------------------------------------------------------
## raster::shapefile("path/to/shapefile")

## ----eval = FALSE--------------------------------------------------------
## # comma-separated
## objname <- read.csv("path/to/file", sep = ",")
## 
## #tab-separated
## objname <- read.table("path/to/file", sep = "\t")

## ------------------------------------------------------------------------
1
1.1
0.314

## ------------------------------------------------------------------------
str(1)

## ------------------------------------------------------------------------
x <- 0.314

## ------------------------------------------------------------------------
x
print(x)

## ------------------------------------------------------------------------
str(x)

## ------------------------------------------------------------------------
y <- 5
str(y)
y <- as.integer(5)
str(y)

## ------------------------------------------------------------------------
str('Radar')

## ----eval = FALSE--------------------------------------------------------
## str(Radar)

## ------------------------------------------------------------------------
days_of_week <- factor(c("Sunday","Monday","Tuesday","Wednesday",
                         "Thursday","Friday","Saturday"))

str(days_of_week)

levels(days_of_week)

## ------------------------------------------------------------------------
days_of_week <- factor(c("Sunday","Monday","Tuesday","Wednesday",
                         "Thursday","Friday","Saturday"),
                       levels = c("Sunday","Monday","Tuesday","Wednesday",
                         "Thursday","Friday","Saturday"))

levels(days_of_week)

## ------------------------------------------------------------------------
is.logical(TRUE)
is.logical(T)
as.logical(c(1,0,1,0,0))

## ------------------------------------------------------------------------
c(1,2,3,4,5)

c("Ovenbird","American Redstart","Black-throated Blue Warbler")

## ------------------------------------------------------------------------
c("Ovenbird",1,2,"American Redstart")

str(c("Ovenbird",1,2,"American Redstart"))

## ------------------------------------------------------------------------
mat <- matrix(1:100, nrow = 10, ncol = 10, byrow = TRUE)
str(mat)
mat

## ------------------------------------------------------------------------
mat[2,1]

## ------------------------------------------------------------------------
# Let's get all the values in the 10th row
mat[10,]

# all the values in 10th column
mat[,10]  

## ------------------------------------------------------------------------
# dim = c(rows,columns,dimension)
array.data <- array(1:100, dim = c(5,2,2)) 

str(array.data)
array.data

## ------------------------------------------------------------------------
# get all columns from 3rd row, 2nd dimension
array.data[3,,2] 

## ------------------------------------------------------------------------
xx <- data.frame(id = c("a","b","c","d","e"),
                 vals = 1:5,
                 values = 1.1:5.1)
str(xx)

## ------------------------------------------------------------------------
xy <- data.frame(seq(1,100,by = 1),
                 rep(2,100),
                 log(seq(1,100,by = 1)))
str(xy)

## ------------------------------------------------------------------------
colnames(xy)<-c("class","test","values")
str(xy)

## ------------------------------------------------------------------------
# first 5 values
xy$values[1:5] 

## ------------------------------------------------------------------------
# first 5 values of 3rd column
xy[1:5,3] 

## ------------------------------------------------------------------------
list.data <- list(id = 1:5,
                  names = c("Dr. Seuss","Cat in the hat"),
                  DataFrame = data.frame(starttimes = rnorm(10),
                                         endtimes = runif(10,20,30)))

## ------------------------------------------------------------------------
str(list.data)
list.data

## ------------------------------------------------------------------------
list.data[[3]][5,1]
list.data[[3]]$starttime[5]
list.data$DataFrame$starttime[5]

