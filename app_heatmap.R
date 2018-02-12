library(tidyverse)
library(lubridate)

# Load data
logdata <- read_csv("https://georoen.github.io/heuteZensiert/Logfile.csv") %>% 
  select(date:prozent) %>% 
  transmute(date = as.Date(date),
            sender = factor(ifelse(grepl("h", sendung), "ZDF", "ARD")),
            sendung = factor(sendung, labels = c("Heute 19Uhr", "Heute Journal",
                                                 "Tageschau", "Tagesthemen")),
            prozent = as.numeric(gsub("%", "", prozent))) %>% 
  mutate(WDay = lubridate::wday(date, label = T, abbr = F, week_start = 1),
         WDay = forcats::fct_rev(WDay),
         Week = lubridate::isoweek(date),  # Isoweek starts with Monday
         Month = lubridate::month(date),
         Year = lubridate::year(date)) %>% 
  arrange(desc(date))

edges <- logdata %>% 
  # Fill Missing Values (Weekly)
  # spread(WDay, prozent) %>%
  # gather(WDay, prozent, 6:13) %>%
  #
  filter(lubridate::day(date) <= 7) %>%
  # Close vertical line under "Sunday" and Bottom hline
  group_by(Year, Month) %>% 
  select(WDay, Week) %>% 
  distinct() %>% 
  nest() %>% 
  mutate(data = map(data, function(x){
    x %>% 
      rbind(c(0, min(x$Week))) %>%  # Add Point at Day = 0.5 in first weerk
      arrange(WDay)})) %>% 
  unnest() %>% 
  # Style 4 geom_tile
  mutate(Week = as.numeric(Week)-0.5,
         WDay = as.numeric(WDay)+0.5) 
  

# Plot
ggplot(logdata, aes(Week, as.numeric(WDay))) +
  geom_tile(aes(fill = prozent)) +
  # geom_point(data = edges) +
  geom_step(data = edges, aes(group=Month)) +
  geom_hline(yintercept = c(0.5, 7.5)) +
  # geom_contour(aes(x = Week, y = as.numeric(Day), z = Month), binwidth = 1) +
  # geom_contour(aes(z = Month), binwidth = 1) +
  scale_fill_continuous(low = "lightgreen", high = "red") +
  scale_y_continuous(breaks = c(1:7), labels = levels(logdata$WDay)) +
  facet_grid(sendung ~ Year, scales = "free_x") +
  labs(x = "Kalenderwoche", y = "") 
