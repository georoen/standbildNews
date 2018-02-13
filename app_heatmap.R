library(tidyverse)
library(lubridate)

# Load data
logdata <- read_csv("https://georoen.github.io/heuteZensiert/Logfile.csv") %>% 
  select(date:prozent) %>% 
  transmute(date = as.Date(date),
            sender = factor(ifelse(grepl("^h", sendung), "ZDF", "ARD")),
            sendung = factor(sendung, labels = c("Heute 19Uhr", "Heute Journal",
                                                 "Tageschau", "Tagesthemen")),
            prozent = as.numeric(gsub("%", "", prozent))) %>% 
  arrange(desc(date))

# Preprocess
df <- logdata %>% 
  mutate(WDay = lubridate::wday(date, label = T, abbr = F, week_start = 1),
         WDay = forcats::fct_rev(WDay),
         Week = lubridate::isoweek(date),  # Isoweek starts with Monday
         Month = lubridate::month(date),
         Year = lubridate::year(date)) %>% 
  arrange(desc(date)) %>% 
  # Fill Missing Values (Weekly)
  group_by(sender, sendung, Year) %>%
  nest() %>% 
  mutate(data = map(data, function(x){x %>% complete(Week, WDay)})) %>% 
  unnest() %>% 
  mutate(date = if_else(!is.na(date), date, # Fill missing Dates
                        as.Date(paste(WDay, Week, Year), "%A %V %Y")),
         Month = lubridate::month(date))

# Month Grid
edges <- df %>% 
  # As numeric to ease shifting
  mutate(WDay = as.numeric(WDay),
         Week = as.numeric(Week)) %>% 
  # Select frist 7 days of month.
  filter(lubridate::day(date) <= 7) %>%
  # Add day 0. Closes vertical line under "Sunday" and Bottom hline
  group_by(sendung, Year, Month) %>% 
  select(WDay, Week) %>% 
  nest() %>% 
  mutate(data = map(data, function(x){
    x %>% 
      rbind(c(0, min(x$Week))) %>%  # Add Point at Day = 0.5 in first weerk
      arrange(WDay)})) %>% 
  unnest() %>% 
  # Shift by 0.5 to match geom_tile()
  mutate(Week = Week-0.5,
         WDay = WDay+0.5) 
  

# Plot
ggplot(df, aes(Week, as.numeric(WDay))) +
  geom_tile(aes(fill = prozent)) +
  scale_fill_continuous(low = "lightgreen", high = "red") +
  # Month Grid
  # geom_point(data = edges) +
  geom_step(data = edges, aes(group=Month)) +
  geom_hline(yintercept = c(0.5, 7.5)) +
  # Scales, Labs, Theme
  scale_y_continuous(breaks = c(1:7), labels = levels(df$WDay)) +
  facet_grid(sendung ~ Year, scales = "free_x") +
  labs(x = "Kalenderwoche", y = "") 
