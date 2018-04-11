# File to deploy shiny app
library(rsconnect)
setwd("C:/Users/user/Dropbox/R_project/ucrdatatool")
deployApp(appFiles = c("shiny_data/", "about.md",
                       "server.R", "ui.R", "global.R"),
          appTitle = "ucrdatatool")
