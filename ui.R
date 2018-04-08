
  shinyUI(fluidPage(
    useShinyjs(),
    sidebarLayout(
      sidebarPanel(
        HTML("Enter a police agency to see the
             crime over time"),
        selectInput("state",
            label = "State:",
            selected = "California",
            choices = sort(unique(ucr$state))),
        uiOutput("agencies"),
        selectInput("crime",
                  label = "Crime:",
                  selected = "Murder",
                  choices = crimes$shiny_names),
        checkboxInput("rate", label = "Rate per 100,000 Population", value = FALSE),
        checkboxGroupInput("crime_type", label = h3("Type of Crime"),
                           choices = list("Actual"                 = "act_",
                                          "Clearance"              = "clr_",
                                          "Clearance under age 18" = "clr_18_",
                                          "Unfounded"              = "unfound_"),
                           selected = "act_"),
      downloadButton('downloadData', 'Download Table')),

      # Show a plot of the crime!
      mainPanel(
        dygraphOutput("crimePlot", height = "550px"),
        tableOutput('mytable1')
      )
    )
  ))