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

    if (is.null(input$agency) | length(ucr$state[ucr$state == input$state &
                                                 ucr$agency == input$agency]) == 0 |
        is.null(input$crime_type)) {
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
        select(year, crime)
      names(ucr) <- str_replace_all(names(ucr), crime_names)
      names(ucr) <- str_replace_all(names(ucr), col_names)
      ucr %>%
        dygraph(main = paste0(input$agency, ": ", input$crime)) %>%
        dyRangeSelector() %>%
        dyAxis(name = "y", label = graph_label) %>%
        dyCrosshair(direction = "vertical")
    }
  })

  output$mytable1 <- renderDataTable({
    starting_cols <- c("year", "agency", "state", "ori", "population")
    pretty_cols <- names(ucr)[!names(ucr) %in% c("agency", "state",
                                                 "ori", "year")]
    crime <- crime()

    if (is.null(input$agency) |
        length(ucr$state[ucr$state == input$state &
                         ucr$agency == input$agency]) == 0) {
      names_ucr <- names(ucr)
      ucr <- suppressWarnings(data.frame(matrix(data = rep("",
                                                           ncol(ucr)),
                                                ncol = ncol(ucr),
                                                nrow = 0)))
      names(ucr) <- names_ucr
    } else if (is.null(input$crime_type)) {

      ucr <- ucr %>%
        select(starting_cols, everything()) %>%
        filter(state == input$state & agency == input$agency) %>%
        arrange(desc(year))
    } else {
      ucr <- ucr %>%
        select(starting_cols, crime, everything()) %>%
        filter(state == input$state & agency == input$agency) %>%
        arrange(desc(year))
    }

    if (input$rate) {

      all_crime_cols <- which(names(ucr) %in% all_crime_cols)
      ucr <- ucr %>%
        mutate_at(all_crime_cols, funs(. / population * 100000)) %>%
        mutate_at(all_crime_cols, funs(round(., digits = 2)))

    }

    crime_cols <- which(names(ucr) %in% crime)
    ucr[, pretty_cols] <- sapply(ucr[, pretty_cols],
                                 prettyNum, big.mark = ",")
    names(ucr) <- stringr::str_replace_all(names(ucr), crime_names)
    names(ucr) <- stringr::str_replace_all(names(ucr), col_names)
    names(ucr) <- sapply(names(ucr), simple_cap)
    names(ucr) <- gsub("^ori$", "ORI", names(ucr), ignore.case = TRUE)

    if (input$rate) {
      names(ucr)[all_crime_cols] <- paste0(names(ucr)[all_crime_cols],
                                           " Rate")
    }


    dt <- DT::datatable(ucr, class = 'cell-border stripe',
                        rownames = FALSE,
                        extensions = c('Scroller', "FixedColumns"),
                        options = list(
                          deferRender = TRUE,
                          scrollY = 400,
                          scroller = TRUE,
                          dom = 't',
                          ordering = FALSE,
                          scrollX = TRUE,
                          fixedColumns = list(leftColumns = 1)))
    if (is.null(input$crime_type)) return(dt)

      dt %>% DT::formatStyle(crime_cols,
                                   fontWeight = "bold",
                                   backgroundColor = "grey",
                                   color = "white",
                                   textAlign = "right")

  })

  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = function() {
      if (input$rate) {
        type <- "rate"
      } else type <- "count"
      paste0(input$agency, " ", input$state, " ", type, ".csv")
    },
    content = function(file) {
      starting_cols <- c("year", "agency", "state", "ori", "population")
      if (!is.null(input$crime_type)) {
        ucr <- ucr %>%
          select(starting_cols, crime(), everything())
      }
      ucr <- ucr %>% filter(state == input$state & agency == input$agency)

      if (input$rate) {
        ucr <- ucr %>%
          mutate_at(all_crime_cols, funs(. / population * 100000)) %>%
          mutate_at(all_crime_cols, funs(round(., digits = 2)))
        type <- "rate"
        all_crime_cols <- which(names(ucr) %in% all_crime_cols)
        names(ucr)[all_crime_cols] <- paste0(names(ucr)[all_crime_cols], "_rate")
      }
      readr::write_csv(ucr, file)
    }
  )

})
