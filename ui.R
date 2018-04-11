shinyUI(fluidPage(theme = shinythemes::shinytheme("flatly"),

                  # Application title
                  navbarPage("UCR Data Tool",
                             tabPanel("Crimes",
  useShinyjs(),
  sidebarLayout(
    sidebarPanel(
      HTML("Enter a police agency to see its crime over time"),
      selectInput("state",
                  label = "State:",
                  selected = "California",
                  choices = sort(unique(ucr$state))),
      uiOutput("agencies"),
      selectInput("crime",
                  label = "Crime:",
                  selected = "Murder",
                  choices = crimes$shiny_names),
      # checkboxGroupInput("all_agencies", label = NULL,
      #                    choices = list("All Agencies"  = "all_agencies",
      #                                   "Consistent ORIs" = "consistent_oris"),
      #                    selected = "consistent_oris",
      #                    inline = TRUE),
      checkboxInput("rate", label = "Rate per 100,000 Population", value = FALSE),
      checkboxGroupInput("crime_type", label = h3("Type of Crime"),
                         choices = list("Actual"                 = "act_",
                                        "Clearance"              = "clr_",
                                        "Clearance under age 18" = "clr_18_",
                                        "Unfounded"              = "unfound_"),
                         selected = "act_"),
      downloadButton('downloadData', 'Download Table'),
      helpText(paste0("Data are available for agencies that report data",
                      " for all 12 months of the year."))),

    # Show a plot of the crime!
    mainPanel(
      dygraphOutput("crimePlot", height = "550px")
    )
  ),
  DTOutput('mytable1')
),
# tabPanel("Arrests"),
# tabPanel("Police Killed/Assaulted"),
# tabPanel("Supplementary Homicide Report"),
# tabPanel("Hate Crimes")
tabPanel("About",
         includeMarkdown("about.md"))

)))