
shinyServer(function(input, output) {

  output$agencies <- renderUI({
    selectInput("agency",
                label = "Agency:",
                selected = "Oakland Police Department",
                choices = sort(unique(ucr$agency[ucr$state == input$state])))
  })


  crime <- reactive({
    crime <- crimes$real_names[crimes$shiny_names == input$crime]
    if (!grepl("officer", crime, ignore.case = TRUE)) {
      crime <- paste0(input$crime_type, crime)
    }
    crime
  })

  observeEvent(input$crime, {
    if (grepl("officer", input$crime, ignore.case = TRUE)) {
      disable("crime_type")
    } else {
      enable("crime_type")
    }
  })


  output$crimePlot <- renderDygraph({

    crime <- crime()

    ucr %>%
      filter(state == input$state & agency == input$agency) %>%
      select(year, crime) %>%
      dygraph(main = paste0(input$crime, " in ", input$agency)) %>%
      dyRangeSelector() %>%
      dyAxis(name = "y", label = "# of Crimes")

  })

  output$mytable1 <- function() {
    starting_cols <- c("agency", "state", "ori", "year", "population")
    crime <- crime()

    ucr <- ucr %>%
      select(starting_cols, crime, everything()) %>%
      filter(state == input$state & agency == input$agency) %>%
      arrange(desc(year))
    crime_col <- which(names(ucr) %in% crime)
    names(ucr) <- sapply(names(ucr), simple_cap)
    names(ucr) <- stringr::str_replace_all(names(ucr), crime_names)
    names(ucr) <- stringr::str_replace_all(names(ucr), col_names)
    ucr %>%
      knitr::kable("html") %>%
      kable_styling(c("striped", "hover", "responsive")) %>%
      column_spec(crime_col, bold = TRUE, background = "grey", color = "white")

  }

  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0(input$agency, "_", input$state, ".csv")
    },
    content = function(file) {
      readr::write_csv(ucr %>%
                         filter(state == input$state & agency == input$agency), file)
    }
  )

})
