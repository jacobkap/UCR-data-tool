library(shiny)
library(ggplot2)
library(ggthemes)
library(scales)
library(readr)
library(kableExtra)
library(dplyr)
library(dygraphs)
library(stringr)
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


col_names <- c("Act_"         = "Actual ",
               "Clr_"         = "Clearance ",
               "18_"          = "under 18",
               "Unfound_"     = "Unfounded",
               "_kill_by_fel" = " Killed by Accident",
               "_kill_by_acc" = " Killed by Felony",
               "_assaulted"   = " Assaulted")