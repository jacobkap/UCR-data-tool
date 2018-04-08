shinyServer(function(input, output) {

  output$agencies <- renderUI({

    selected_agency <- ucr %>%
      filter(state == input$state) %>%
      top_n(1, population) %>%
      select(agency)

    selectInput("agency",
                label = "Agency:",
                selected = selected_agency$agency,
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
    graph_label <- "# of Crimes"

    if (is.null(input$agency) || length(ucr$state[ucr$state == input$state &
                                                 ucr$agency == input$agency]) == 0) {
      dygraph(data.frame(year = 1960:2016, crime = rep(0, 57)))
    } else {
      ucr <- ucr %>%
        filter(state == input$state & agency == input$agency)
      if (input$rate) {
        graph_label <- "Rate per 100,000 Population"
        ucr <- ucr %>%
          select(year, crime, population) %>%
          mutate_at(crime, funs(. / population * 100000))
      }
      ucr <- ucr %>%
        select(year, crime) %>%
        dygraph(main = paste0(input$agency, ": ", input$crime)) %>%
        dyRangeSelector() %>%
        dyAxis(name = "y", label = graph_label)
    }
    ucr
  })

  output$mytable1 <- function() {
    starting_cols <- c("agency", "state", "ori", "year", "population")
    pretty_cols <- names(ucr)[!names(ucr) %in% c("agency", "state",
                                            "ori", "year")]
    crime <- crime()

    if (is.null(input$agency) || length(ucr$state[ucr$state == input$state &
                                                 ucr$agency == input$agency]) == 0) {
      ucr2 <- data.frame(matrix(data = rep("", ncol(ucr)),
                                ncol = ncol(ucr),
                                nrow = 1))
      names(ucr2) <- names(ucr)
      ucr <- ucr2 %>%
        select(starting_cols, crime, everything())
    } else {
      ucr <- ucr %>%
        select(starting_cols, crime, everything()) %>%
        filter(state == input$state & agency == input$agency) %>%
        arrange(desc(year))
    }
    crime_cols <- which(names(ucr) %in% crime)
    ucr[, pretty_cols] <- sapply(ucr[, pretty_cols],  prettyNum, big.mark = ",")
    names(ucr) <- sapply(names(ucr), simple_cap)
    names(ucr) <- stringr::str_replace_all(names(ucr), crime_names)
    names(ucr) <- stringr::str_replace_all(names(ucr), col_names)


    ucr %>%
      knitr::kable("html") %>%
      kable_styling(c("striped", "hover", "responsive")) %>%
      column_spec(crime_cols,
                  bold = TRUE,
                  background = "grey",
                  color = "white")

    }

  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0(input$agency, " ", input$state, ".csv")
    },
    content = function(file) {
      starting_cols <- c("agency", "state", "ori", "year", "population")
      readr::write_csv(ucr %>%
                         select(starting_cols, crime(), everything()) %>%
                         filter(state == input$state & agency == input$agency), file)
    }
  )

})
