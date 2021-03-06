---
title: "Introduction to the tidyverse"
authors: "Clark S. Rushing"
contributors: "Michael T. Hallworth"
header:
  caption: 'Photo credit: **M. T. Hallworth**'
  image: assets/images/lookingUp.jpg
layout: single
permalink: /_pages/tidyverse_basics
sidebar:
  nav: "SpatialWorkshop"
  title: "Get Spatial! Using R as GIS"
classes: wide
---

## What is the tidyverse?
If you have been using R over the last several years, you've probably noticed an ever-growing number of R enthusiasts extolling the virtues of the [tidyverse](https://www.tidyverse.org/), "an opinionated collection of R packages designed for data science." The tidyverse is built around several core packages, including `dplyr`, `tidyr`, `ggplot2`, and `purrr`, plus many others that provide more specialized solutions for common data science problems. All packages in the tidyverse share a common philosophy about data structure, coding style, and workflow, which allows tidyverse functions to work together more-or-less seamlessly. Although not all R users agree with this philosophy or like using the tidyverse, the main advantages of the tidyverse include: 

  - **Consistent data input/output structure**: The tidyverse is built around data frames. This means that, for the most part, tidyverse functions take a data frame as input and produce a new data frame as output. Perhaps more importantly, tidyverse functions are built around ['tidy'](http://vita.had.co.nz/papers/tidy-data.pdf) data frames - i.e., data frames where each row is a single observation and each column is a variable. Although not the most compact way to store data, tidy data has many advantages for manipulation, modeling, and visualization. 
  - **Intuitive function names**: To the extent possible, tidyverse functions strive to have intuitive names so users can more easily understand what a function does. Examples include `filter`, `arrange`, `summarise`, and `group_by`.
  - **Consistent style**: Tidyverse functions use a common [style guide](http://style.tidyverse.org/index.html). This means that naming conventions (e.g., functions names are verbs, all lower case with words separated by `_`), argument order (e.g., data is always the first argument), spacing and indentations, etc. are consistent across all tidyverse packages. As Hadley Wickham put it, this consistency "is like correct punctuation: you can manage without it, butitsuremakesthingseasiertoread".
  - **Piping functions**: Rather than nesting functions (e.g. `head(mean())`), tidyverse functions can be sequentially linked using the pipe operator `%>%`. This greatly increases readability of code. 
