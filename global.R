library(shiny)
library(ggplot2)
library(ggthemes)
library(scales)
library(lubridate)
library(readr)
load("master_crime.rda")

simpleCap <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
        sep = "", collapse = " ")
}