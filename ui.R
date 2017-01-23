
  shinyUI(fluidPage(

    # Application title
    titlePanel("UCR Data Tool"),


    sidebarLayout(
      sidebarPanel(
        HTML("Enter a police agency to see the
             crime over time"),
        selectInput("agency",
            label = "Agency Name:",
            selected =
            sample(unique(master_crime$location[master_crime$murder > 100]), 1),
            choices = unique(master_crime$location),
            multiple = TRUE),
        selectInput("crime",
                  label = "Crime:",
                  selected = "Murder",
                  choices = c("Murder", "Rape", "Robbery",
                              "Simple Assault",
                              "Aggravated Assault", "Burglary",
                              "Motor Vehicle Theft", "Larceny",
                              "Violent", "Property", "All"),
                  multiple = FALSE),
        checkboxInput("rate", label = "Rate per 100,000 Population", value = FALSE),
      sliderInput("yearRange", label = h3("Year Range"), min = 1960,
                  max = 2015, value = c(1960, 2015)),
      textInput("title", label = "Graph Title", value = "Enter graph title"),
      downloadButton('downloadData', 'Download Table')),


      # Show a plot of the crime!
      mainPanel(
        plotOutput("crimePlot"),
        dataTableOutput('mytable1')
      )
    )
  ))