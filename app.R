# Load packages
library(shiny)
library(shinythemes)
library(dplyr)
library(readr)

# Load data
logdata <- read_csv("https://georoen.github.io/heuteZensiert/Logfile.csv") %>% 
  arrange(date) %>% 
  mutate(prozent = as.numeric(gsub("%", "", prozent)),
         date = as.POSIXct(date))

# Define UI
ui <- fluidPage(theme = shinytheme("lumen"),
                titlePanel("Google Trend Index"),
                sidebarLayout(
                  sidebarPanel(
                    
                    # Select type of trend to plot
                    selectInput(inputId = "sendung", label = strong("sendung index"),
                                choices = unique(logdata$sendung),
                                selected = "Sendung"),
                    
                    # Select date range to be plotted
                    dateRangeInput("date", strong("Date range"), start = "2017-10-21", end = Sys.Date(),
                                   min = "2017-10-21", max = Sys.Date())
                  ),
                  
                  # Output: Description, lineplot, and reference
                  mainPanel(
                    plotOutput(outputId = "lineplot", height = "300px"),
                    textOutput(outputId = "desc"),
                    tags$a(href = "https://www.google.com/finance/domestic_trends", "Source: Google Domestic Trends", target = "_blank")
                  )
                )
)

# Define server function
server <- function(input, output) {
  
  # Subset data
  selected_logdata <- reactive({
    req(input$date)
    validate(need(!is.na(input$date[1]) & !is.na(input$date[2]), "Error: Please provide both a start and an end date."))
    validate(need(input$date[1] < input$date[2], "Error: Start date should be earlier than end date."))
    logdata %>%
      filter(
        sendung == input$sendung,
        date > as.POSIXct(input$date[1]) & date < as.POSIXct(input$date[2]
        ))
  })
  
  
  # Create scatterplot object the plotOutput function is expecting
  output$lineplot <- renderPlot({
    color = "#434343"
    # par(mar = c(4, 4, 1, 1))
    ggplot(selected_logdata(), aes(date, prozent, color = sendung)) +  geom_point()
    # plot(x = selected_logdata()$date, y = selected_logdata()$prozent, type = "l",
    #      xlab = "Date", ylab = "Trend index", col = color, fg = color, col.lab = color, col.axis = color)
  })
  
  # Pull in description of trend
  output$desc <- renderText({
    trend_text <- filter(trend_description, type == input$type) %>% pull(text)
    paste(trend_text, "The index is set to 1.0 on January 1, 2004 and is calculated only for US search traffic.")
  })
}

# Create Shiny object
shinyApp(ui = ui, server = server)