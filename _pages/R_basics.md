---
title: "R basics"
authors: "Michael T. Hallworth"
contributors: "Clark S. Rushing & Matt Boone"
layout: single
classes: wide
permalink: /_pages/R_basics
header:
  caption: 'Photo credit: **M. T. Hallworth**'
  image: assets/images/lookingUp.jpg
sidebar:
  title: "Get Spatial! Using R as GIS"
  nav: "SpatialWorkshop"
---
<a name="TOP"></a>

{% include toc title="In This Activity" %}

# Getting started in R

## Obtaining R packages 

Packages are a suite of functions that are packaged together. There are a few places where packages are stored. [CRAN]("https://cran.r-project.org/web/packages/index.html") is the primary place where packages are held. [GitHub]("https://github.com/") is another place where packages / code is stored and can be accessed in R. Other online repositories such as [Bioconductor]("https://www.bioconductor.org/packages/release/bioc/") also exist. 

Here is one way to get a package.

```r
install.packages(pkgs = c("devtools"), dependencies = TRUE)
```

In order to get packages from Github you also need the `devtools` package.

```r
devtools::install_github("Username/repository")
```

## Loading packages
In order to use the functions within packages you first need to load the library into the working environment. Note that functions are loaded into the working environment in the order you load them into R. Sometimes packages use the same name for functions that do very different things. If for example package A has a function called 'toLetter' and package B also has a function called 'toLetter' the order in which you load the packages into R will determine which 'toLetter' function is called first. 


```r
library(raster)
```
When sharing code with other people it's good etiquette to place the library where the function comes from before the function call. This reduces the likelihood that functions are masked by other packages. Placing the package before the function ensures the correct function is used. The syntax below means "use the shapefile function found in the raster package" to read in the shapefile found at "path/to/shapefile"


```r
raster::shapefile("path/to/shapefile")
```

<a href="#TOP">back to top</a>

## Reading in data
There are several ways to read data into R. Perhaps the most commonly used is the `read.csv` function which is a special function within the `read.table` function. 

```r
# comma-separated
objname <- read.csv("path/to/file", sep = ",")

#tab-separated
objname <- read.table("path/to/file", sep = "\t") 
```


# Introduction to R

### Basics 

[R]("https://www.r-project.org/") is a language and a suite of software for programming, data analysis and graphics.

**R** is used interchangeably to refer to be the program and the programming language

### R Studio

[RStudio](https://www.rstudio.com/") is a graphical user interface where users interact with R. It's a great way to use and learn R programming language. There are many benefits of using RStudio, too many to list here but here are a few. First, RStudio allows users to see and explore variables that are loaded within the working environment. Second, searching for help files is very easy. Third, all aspects of R (scripts, console, plots, & github terminal) are easily accessible and visible. 

<a href="#TOP">back to top</a>

## Data Classes in R

R has 5 main data types but there are many that are available. Data classes tell R what objects are in the environment and set the operations that are availble for that object. The main data types are:    
1) **Numeric**    
2) **Integer**    
3) **Character**    
4) **Factor**    
5) **Logical**

Let's dive into each of the above data classes and see what they look like in R. In the next few sections you'll see some examples of the different data classes. We'll be using the `str` function which shows the structure of an object in R. 

### Numeric
Let's see what happens when we add numbers into R. 

```r
1
```

```
## [1] 1
```

```r
1.1
```

```
## [1] 1.1
```

```r
0.314
```

```
## [1] 0.314
```

Let's have a closer look at the structure (`str`) of a numeric variable in R.

```r
str(1)
```

```
##  num 1
```

Below we define an object in R. We'll provide the object with a name (in this case 'x') and a value (0.314).

```r
x <- 0.314
```

We can then print the object to the console and see what it contains. We can do that a few ways. First, we can just type the object name and then run the code or we can use the `print` function.

```r
x
```

```
## [1] 0.314
```

```r
print(x)
```

```
## [1] 0.314
```
Let's double check that the object `x` is numeric. 

```r
str(x)
```

```
##  num 0.314
```

### Integers   
Integers are also numeric but integers are whole numbers with no decimal. 

```r
y <- 5
str(y)
```

```
##  num 5
```

```r
y <- as.integer(5)
str(y)
```

```
##  int 5
```

### Character    
Character data classes are letters - they have no numeric value associated with them. The "" or '' notation tells R that you are assigning something to a character and not calling an object. *note - you can assign numbers to class character*


```r
str('Radar')
```

```
##  chr "Radar"
```

What would happen if you forget to use the '' or "" when assigning a character? 


```r
str(Radar)
```

### Factor
Factors are character strings that have some sort of order. For example, days of the week (Sunday, Monday, Tues, etc.). In this case, the characters represent objects with an inherent value. 


```r
days_of_week <- factor(c("Sunday","Monday","Tuesday","Wednesday",
                         "Thursday","Friday","Saturday"))

str(days_of_week)
```

```
##  Factor w/ 7 levels "Friday","Monday",..: 4 2 6 7 5 1 3
```

```r
levels(days_of_week)
```

```
## [1] "Friday"    "Monday"    "Saturday"  "Sunday"    "Thursday"  "Tuesday"  
## [7] "Wednesday"
```

Notice that the levels aren't how we specified them. What is the default order in R? 

If we want the factor levels to be in the order we specified we can use the following code. We can explicitly tell R what the levels are and the order of the levels. 


```r
days_of_week <- factor(c("Sunday","Monday","Tuesday","Wednesday",
                         "Thursday","Friday","Saturday"),
                       levels = c("Sunday","Monday","Tuesday","Wednesday",
                         "Thursday","Friday","Saturday"))

levels(days_of_week)
```

```
## [1] "Sunday"    "Monday"    "Tuesday"   "Wednesday" "Thursday"  "Friday"   
## [7] "Saturday"
```

### Logical 
Logical is TRUE or FALSE. There are only two possible states, yes or no, on or off. R understands a few different ways to specify a logical. They can be represented in three ways, T or F for True and False, TRUE or FALSE and 1 or 0. 

```r
is.logical(TRUE)
```

```
## [1] TRUE
```

```r
is.logical(T)
```

```
## [1] TRUE
```

```r
as.logical(c(1,0,1,0,0))
```

```
## [1]  TRUE FALSE  TRUE FALSE FALSE
```

<a href="#TOP">back to top</a>

## Data Types
R has four main data types. These are structural types that data can be stored in. They are defined by if they take more than class type and the dimensions of the data.

### Vectors
Vectors are one dimensional data sets where the only dimension is length. They can only consist of a single data class (Numeric,Character,Logical,etc). Vectors are created using the <code>c()</code> syntax.


```r
c(1,2,3,4,5)
```

```
## [1] 1 2 3 4 5
```

```r
c("Ovenbird","American Redstart","Black-throated Blue Warbler")
```

```
## [1] "Ovenbird"                    "American Redstart"          
## [3] "Black-throated Blue Warbler"
```

If data class types are mixed within a vector, R attempts to coherse the data into a class that all elements have in common. For example, if we combine a numeric element with two character elements R will convert the numeric element into a character. 

```r
c("Ovenbird",1,2,"American Redstart")
```

```
## [1] "Ovenbird"          "1"                 "2"                
## [4] "American Redstart"
```

```r
str(c("Ovenbird",1,2,"American Redstart"))
```

```
##  chr [1:4] "Ovenbird" "1" "2" "American Redstart"
```

### Matrix / array
Matrices are two dimensional containers where all data have the same data type. The dimensions are rows and columns. Array's are multi-dimensional matrices where all data are the same data type. The dimensions of an array can take many forms but at the very least they have rows and columns. In fact, matrices are a special form of an array - array with only two dimensions.


```r
mat <- matrix(1:100, nrow = 10, ncol = 10, byrow = TRUE)
str(mat)
```

```
##  int [1:10, 1:10] 1 11 21 31 41 51 61 71 81 91 ...
```

```r
mat
```

```
##       [,1] [,2] [,3] [,4] [,5] [,6] [,7] [,8] [,9] [,10]
##  [1,]    1    2    3    4    5    6    7    8    9    10
##  [2,]   11   12   13   14   15   16   17   18   19    20
##  [3,]   21   22   23   24   25   26   27   28   29    30
##  [4,]   31   32   33   34   35   36   37   38   39    40
##  [5,]   41   42   43   44   45   46   47   48   49    50
##  [6,]   51   52   53   54   55   56   57   58   59    60
##  [7,]   61   62   63   64   65   66   67   68   69    70
##  [8,]   71   72   73   74   75   76   77   78   79    80
##  [9,]   81   82   83   84   85   86   87   88   89    90
## [10,]   91   92   93   94   95   96   97   98   99   100
```

This is a good place to stop and talk a little bit about R syntax. In matrices and arrays we can refer to positions within the matrix/array by using square brackets **[row,column]**. The left position within the square brackets refers to the row and the right refers to the column. **data[row,column]**

Let's pull out the value within the second row and first column

```r
mat[2,1]
```

```
## [1] 11
```

You can get all values within a row by leaving the column position empty and vise versa.

```r
# Let's get all the values in the 10th row
mat[10,]
```

```
##  [1]  91  92  93  94  95  96  97  98  99 100
```

```r
# all the values in 10th column
mat[,10]  
```

```
##  [1]  10  20  30  40  50  60  70  80  90 100
```

### Array 
Arrays are multi-dimensional matrices. All data needs to be of the same <code>data.class</code>. Think of arrays as stacked matrices.


```r
# dim = c(rows,columns,dimension)
array.data <- array(1:100, dim = c(5,2,2)) 

str(array.data)
```

```
##  int [1:5, 1:2, 1:2] 1 2 3 4 5 6 7 8 9 10 ...
```

```r
array.data
```

```
## , , 1
## 
##      [,1] [,2]
## [1,]    1    6
## [2,]    2    7
## [3,]    3    8
## [4,]    4    9
## [5,]    5   10
## 
## , , 2
## 
##      [,1] [,2]
## [1,]   11   16
## [2,]   12   17
## [3,]   13   18
## [4,]   14   19
## [5,]   15   20
```

You can pull out the elements within a multi-dimensional array using the **[row,column,dimension]** syntax. 

```r
# get all columns from 3rd row, 2nd dimension
array.data[3,,2] 
```

```
## [1] 13 18
```

### Data.frames
Data.frames have two dimensions where each column has the same data class but columns can differ in their data type. Therefore, data.frames can contain more than one type of data. 

In the below example we combine a character, an integer and a numeric into a single data container called a data.frame. 


```r
xx <- data.frame(id = c("a","b","c","d","e"),
                 vals = 1:5,
                 values = 1.1:5.1)
str(xx)
```

```
## 'data.frame':	5 obs. of  3 variables:
##  $ id    : Factor w/ 5 levels "a","b","c","d",..: 1 2 3 4 5
##  $ vals  : int  1 2 3 4 5
##  $ values: num  1.1 2.1 3.1 4.1 5.1
```

Note - naming of columns within a data.frame can become a little unwieldy if you're not careful. By default the columns are named by the input. 

In the example below we're not as diligent as we were in the example above. You can see how this can get pretty ugly fast.

```r
xy <- data.frame(seq(1,100,by = 1),
                 rep(2,100),
                 log(seq(1,100,by = 1)))
str(xy)
```

```
## 'data.frame':	100 obs. of  3 variables:
##  $ seq.1..100..by...1.     : num  1 2 3 4 5 6 7 8 9 10 ...
##  $ rep.2..100.             : num  2 2 2 2 2 2 2 2 2 2 ...
##  $ log.seq.1..100..by...1..: num  0 0.693 1.099 1.386 1.609 ...
```

We can supply names afer the data.frame is created. 

```r
colnames(xy)<-c("class","test","values")
str(xy)
```

```
## 'data.frame':	100 obs. of  3 variables:
##  $ class : num  1 2 3 4 5 6 7 8 9 10 ...
##  $ test  : num  2 2 2 2 2 2 2 2 2 2 ...
##  $ values: num  0 0.693 1.099 1.386 1.609 ...
```

This becomes important for a few reasons. First, readability and second because we can access data using the column names. To extract data from a data.frame using column names we can use the **\$** operator. **data.frame\$variable**. Below we extract the variable we called 'values' above. 


```r
# first 5 values
xy$values[1:5] 
```

```
## [1] 0.0000000 0.6931472 1.0986123 1.3862944 1.6094379
```
You can also use the **[row,column]** syntax as well to extract data from a data.frame

```r
# first 5 values of 3rd column
xy[1:5,3] 
```

```
## [1] 0.0000000 0.6931472 1.0986123 1.3862944 1.6094379
```
### Lists
Lists are containers for other data types. Lists can contain any data.type and can be any dimension. You can name lists in the same way as column names in data.frames. You can think of lists as a storage container - sort of like a tackle box or jewlery box for you data. Each element of a list can be a different size / type of data. For example, you can store data.frames, arrays, vectors and spatial data in single list. Lists can be complicated at first and getting the exact element of a list you want can take some practice. However, once you get the hang of lists you can do a lot of powerful things with them because they are so flexible. 


```r
list.data <- list(id = 1:5,
                  names = c("Dr. Seuss","Cat in the hat"),
                  DataFrame = data.frame(starttimes = rnorm(10),
                                         endtimes = runif(10,20,30)))
```

```r
str(list.data)
```

```
## List of 3
##  $ id       : int [1:5] 1 2 3 4 5
##  $ names    : chr [1:2] "Dr. Seuss" "Cat in the hat"
##  $ DataFrame:'data.frame':	10 obs. of  2 variables:
##   ..$ starttimes: num [1:10] -1.136 0.982 -0.792 -0.328 1.71 ...
##   ..$ endtimes  : num [1:10] 27.2 25.3 22.2 28.3 23.4 ...
```

```r
list.data
```

```
## $id
## [1] 1 2 3 4 5
## 
## $names
## [1] "Dr. Seuss"      "Cat in the hat"
## 
## $DataFrame
##     starttimes endtimes
## 1  -1.13641891 27.15934
## 2   0.98208075 25.27281
## 3  -0.79237326 22.22250
## 4  -0.32801845 28.27742
## 5   1.71030388 23.40933
## 6   2.02505720 29.02246
## 7   0.00266605 23.67033
## 8   0.29999465 26.07038
## 9  -0.96584180 27.70870
## 10 -1.05030825 24.82813
```
Accessing data stored within lists can be a little tricky.    
Here is an example of how to extract the 5th element of starttime in the DataFrame object in our list.data object. 

```r
list.data[[3]][5,1]
```

```
## [1] 1.710304
```

```r
list.data[[3]]$starttime[5]
```

```
## [1] 1.710304
```

```r
list.data$DataFrame$starttime[5]
```

```
## [1] 1.710304
```

<a href="#TOP">back to top</a>

<a href="https://raw.githubusercontent.com/mhallwor/mhallwor.github.io/develop/Rscripts/R_basics.R" target="_blank" class="btn btn--info">Download R script</a> Last modified: 2019-09-20 18:26:28
