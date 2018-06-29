# Load packages
library(shiny)
library(tidyverse)
library(DT)

# German locale
Sys.setlocale(category = "LC_ALL", locale = "German")

# Load data
logdata <- read_csv("https://georoen.github.io/standbildNews/Logfile.csv") %>% 
  select(date:prozent) %>% 
  transmute(date = as.Date(date),
            sender = factor(ifelse(grepl("^h", sendung), "ZDF", "ARD")),
            sendung = factor(sendung, labels = c("Heute 19Uhr", "Heute Journal",
                                                 "Tagesschau", "Tagesthemen")),
            prozent = as.numeric(gsub("%", "", prozent))) %>% 
  arrange(desc(date))
means <- aggregate(prozent ~ sendung, logdata, mean)

# Define UI
ui <- fluidPage(
  # Output: Tabset w/ plot, summary, and table ----
  tabsetPanel(type = "tabs",
              tabPanel("Sendungen", plotOutput("plot")),
              tabPanel("Boxplot", plotOutput("boxplot")),
              tabPanel("Statistiken", tableOutput("stats")),
              tabPanel("Tabelle", dataTableOutput("view"))
  )
)

# Define server function
server <- function(input, output) {
  
  # Plot
  output$plot <- renderPlot({
    ggplot(logdata, aes(date, prozent/100, color = sendung)) +
      geom_line(alpha = 0.2) +
      geom_smooth(alpha = 0.5, se = FALSE, span = 0.1) +
      geom_point(size = 2) +
      labs(title = "Blockierter Anteil je Nachrichtensendung (in Prozent)",
           y = NULL, x = NULL) +
      theme(legend.position="bottom", legend.title=element_blank()) +
      scale_y_continuous(labels = scales::percent) + 
      scale_color_manual(values = c("darkorange", "darkgrey", "#3284be", "dodgerblue4"))
  })
  output$boxplot <- renderPlot({
    ggplot(logdata, aes(sendung, prozent/100, group = sendung, fill = sendung)) + 
      geom_boxplot(alpha = 0.5) + 
      stat_summary(fun.y = mean, color = "black", geom = "point", 
                   shape = 23, size = 5, show.legend = TRUE, fill = "gold") + 
      geom_text(data = means, 
                aes(label = paste("Durchschn.:", round(prozent, 2), "%"), 
                    y = prozent/100), 
                nudge_y = 0.7/100) + 
      scale_y_continuous(labels = scales::percent) + 
      scale_fill_manual(values = c("darkorange", "darkgrey", "#3284be", "dodgerblue4"),
                        guide = "none") + 
      labs(title = "Zensierter Anteil der Sendung (in Prozent)", 
           x = NULL, y = NULL)
  })
  output$stats <- renderTable({
    logdata %>% 
      group_by(sendung) %>% 
      rename(Sendung = sendung) %>% 
      summarise("Anzahl Sendungen" = n(),
                "Davon vollständig" = as.integer(sum(if_else(prozent == 0, 1, 0))),
                "Zensierter Anteil je Sendung (Mittelwert)" = paste0(round(mean(prozent),1),"%"))
  })
  
  output$view <- renderDataTable(datatable(logdata))  # DT
  
}

# Create Shiny object
shinyApp(ui = ui, server = server)
