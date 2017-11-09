# Load packages
library(shiny)
library(tidyverse)
library(DT)

# German locale
Sys.setlocale(category = "LC_ALL", locale = "German")

# Load data
logdata <- read_csv("https://georoen.github.io/heuteZensiert/Logfile.csv") %>% 
  select(date:prozent) %>% 
  transmute(date = as.Date(date),
            sender = factor(ifelse(grepl("h", sendung), "ZDF", "ARD")),
            sendung = factor(sendung, labels = c("Heute 19Uhr", "Heute Journal",
                                                 "Tageschau")),
            prozent = as.numeric(gsub("%", "", prozent))) %>% 
  arrange(desc(date))
# Define UI
ui <- fluidPage(
  # Output: Tabset w/ plot, summary, and table ----
  tabsetPanel(type = "tabs",
              tabPanel("Sendungen", plotOutput("plot")),
              tabPanel("Statistiken", tableOutput("stats")),
              tabPanel("Tabelle", dataTableOutput("view"))
  )
)

# Define server function
server <- function(input, output) {
  
  # Plot
  output$plot <- renderPlot({
    ggplot(logdata, aes(date, prozent/100, color = sendung)) +
      geom_line(size = 1.5, alpha = 0.5) +
      geom_point(size = 2) +
      labs(title = "Blockierter Anteil je Nachrichtensendung (in Prozent)",
           y = "", x = "") +
      theme(legend.position="bottom", legend.title=element_blank()) +
      scale_y_continuous(labels = scales::percent)
  })
  output$stats <- renderTable({
    logdata %>% 
      group_by(sendung) %>% 
      rename(Sendung = sendung) %>% 
      summarise(Duchschnittlich = paste0(round(mean(prozent),1),"%"))
  })
  
  output$view <- renderDataTable(datatable(logdata))  # DT
  
}

# Create Shiny object
shinyApp(ui = ui, server = server)