library(shiny)
library(ggplot2)
library(ggthemes)
library(scales)
library(readr)
library(kableExtra)
library(dplyr)
library(dygraphs)
library(stringr)
library(DT)
library(shinyjs)
load("shiny_data/ucr.rda")
load("shiny_data/crimes.rda")
load("shiny_data/crime_names.rda")

simple_cap <- function(x) {
  x <- tolower(x)
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
        sep = "", collapse = " ")
}

all_crime_cols <- names(ucr)[grepl("act|clr|found|officer", names(ucr))]

col_names <- c("act_"         = "Actual ",
               "clr_"         = "Clearance ",
               "18_"          = "under 18 ",
               "unfound_"     = "Unfounded ",
               "_kill_by_fel" = " Killed by Accident",
               "_kill_by_acc" = " Killed by Felony",
               "_assaulted"   = " Assaulted",
               "ori"          = "ORI")

dyCrosshair <- function(dygraph,
                        direction = c("both", "horizontal", "vertical")) {
  dyPlugin(
    dygraph = dygraph,
    name = "Crosshair",
    path = system.file("plugins/crosshair.js",
                       package = "dygraphs"),
    options = list(direction = match.arg(direction))
  )
}
