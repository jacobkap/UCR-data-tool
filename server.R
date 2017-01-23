
shinyServer(function(input, output) {

  ucr_temp <- reactive({
    ucr_temp <- master_crime[which(master_crime$location %in%
                                     input$agency),]
    ucr_temp <- ucr_temp[which(ucr_temp$year %in%
                                   input$yearRange[1]:input$yearRange[2]),]
    ucr_temp$location <- NULL
    ucr_temp$violent <- ucr_temp$murder + ucr_temp$rape + ucr_temp$robbery +
                        ucr_temp$simple_assault + ucr_temp$aggravated_assault
    ucr_temp$property <- ucr_temp$burglary + ucr_temp$larceny +
                         ucr_temp$motor_vehicle_theft
    ucr_temp$all <- ucr_temp$violent + ucr_temp$property
    ucr_temp$population <- as.numeric(ucr_temp$population)
    ucr_temp$year <- as.numeric(ucr_temp$year)
    ucr_temp <- data.frame(ucr_temp, stringsAsFactors = FALSE)
                                    })


  crime <- reactive({
    crime <- tolower(input$crime)
    crime <- gsub(" ", "_", crime)
  })

  rate_binary <- reactive({
    rate_binary <- input$rate
  })

  graph_title <- reactive({
    graph_title <- input$title
  })

  output$crimePlot <- renderPlot({

    ucr_temp <- ucr_temp()
    crime <- crime()
    title <- graph_title()
    rate_binary <- rate_binary()

    ucr_temp$rate <- (ucr_temp[, grep(paste0("^", crime, "$"),
                      names(ucr_temp))] / ucr_temp$population) * 100000
    ucr_temp$rate <- round(ucr_temp$rate, 3)

    plot <- ggplot(ucr_temp, aes_string(x = "year", y = crime)) +
      geom_line() +
      theme_fivethirtyeight() +
      theme(axis.title = element_text()) + ylab('# of Incidents') +
      xlab("Year") +
      ggtitle(paste0(title)) +
      scale_x_discrete(
        limits = c(1960, 1970, 1980, 1990, 2000, 2010, 2015),
        labels = c(1960, 1970, 1980, 1990, 2000, 2010, 2015))

  if (rate_binary) {
    plot <- ggplot(ucr_temp, aes_string(x = "year", y = "rate")) +
      geom_line() +
      theme_fivethirtyeight() +
      theme(axis.title = element_text()) + ylab('# of Incidents per 100,000 Population') +
              xlab("Year") +
              ggtitle(paste0(title)) +
              scale_x_discrete(
                limits = c(1960, 1970, 1980, 1990, 2000, 2010, 2015),
                labels = c(1960, 1970, 1980, 1990, 2000, 2010, 2015))
  }
    plot

  })

  output$mytable1 <- renderDataTable({
    ucr_temp <- ucr_temp()
    names(ucr_temp) <- gsub("_", " ", names(ucr_temp))
    names(ucr_temp) <- sapply(names(ucr_temp), simpleCap)
    ucr_temp <- ucr_temp[order(ucr_temp$Year, decreasing = TRUE),]
    ucr_temp <- data.frame(ucr_temp)
    ucr_temp
  })

  output$downloadData <- downloadHandler(
    filename = function() {"UCRdatatool.csv" },
    content = function(file) {
      write_csv(ucr_temp(), file)
    }
  )

})
