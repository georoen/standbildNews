# Load packages
library(shiny)
library(shinythemes)
library(dplyr)
library(readr)
library(ggplot2)
library(curl)

# German locale
Sys.setlocale(category = "LC_ALL", locale = "German")

# Load data
logdata <- read_csv("https://georoen.github.io/heuteZensiert/Logfile.csv") %>% 
  arrange(date) %>% 
  mutate(prozent = as.numeric(gsub("%", "", prozent)),
         date = as.Date(date))
logdata$sendung <- factor(logdata$sendung,
                          labels = c("ZDF Heute 19 Uhr", "ZDF Heute Journal", "ARD Tagesschau"))

# Define UI
ui <- fluidPage(theme = shinytheme("lumen"),
                # titlePanel("Daten Visualisierung"),
                fluidRow(
                  # Select Layers
                  column(4,checkboxInput("showh19", "ZDF Heute 19 Uhr", TRUE)),
                  column(4,checkboxInput("showhjo", "ZDF Heute Journal", TRUE)),
                  column(4,checkboxInput("showt20", "ARD Tagesschau", TRUE))
                  ),
                
                # Output: Description, lineplot, and reference
                plotOutput(outputId = "lineplot", height = "300px"),
                
                # Select date range to be plotted
                fluidRow(dateRangeInput("date", strong("Datum"), start = "2017-10-21", end = Sys.Date(),
                                        min = min(logdata$date), max = Sys.Date(), language = "de", width = "100%"))
                
)

# Define server function
server <- function(input, output) {
  
  # Subset data
  selected_logdata <- reactive({
    # Sendungen
    Sendungen <- levels(logdata$sendung)[c(input$showh19, input$showhjo, input$showt20)]
    # Datum
    req(input$date)
    validate(need(!is.na(input$date[1]) & !is.na(input$date[2]), "Error: Please provide both a start and an end date."))
    validate(need(input$date[1] < input$date[2], "Error: Start date should be earlier than end date."))
    # Filter
    logdata %>%
      filter(
        sendung %in% Sendungen,
        date >= as.Date(input$date[1]) & date <= as.Date(input$date[2]
        ))
  })
  
  
  # Create scatterplot object the plotOutput function is expecting
  output$lineplot <- renderPlot({
    color = "#434343"
    # par(mar = c(4, 4, 1, 1))
    ggplot(selected_logdata(), aes(date, prozent, color = sendung)) +
      geom_line(alpha = 0.5) + geom_point(size=2) +
      labs(y = "Zensierter Anteil") +
      theme(legend.position="top", legend.title=element_blank())
  })
  
}

# Create Shiny object
shinyApp(ui = ui, server = server)