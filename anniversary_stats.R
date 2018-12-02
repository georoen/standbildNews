library(dplyr)
library(lubridate)
library(ggplot2)

x <- read.csv("Logfile.csv", stringsAsFactors = FALSE)
x$date <- as.Date(x$date)
x <- as_data_frame(x)
date_all <- x %>% distinct(date, sendung) %>% 
group_by(sendung) %>% summarize(start_date = min(date), n = n()) %>% na.omit() %>% pull(start_date) %>% max()

x1 <- x %>% filter(date >= date_all) %>% 
  mutate(prozent_num = as.numeric(gsub("%", "", prozent))) %>% 
  na.omit() %>% 
  mutate(sendung = gsub("h19", "ZDF Heute 19 Uhr", sendung), 
         sendung = gsub("hjo", "ZDF Heute Journal", sendung),
         sendung = gsub("t20", "ARD Tagesschau", sendung),
         sendung = gsub("tth", "ARD Tagesthemen", sendung), 
         res_sec = as.numeric(gsub("^.*/", "", res)), 
         sender = ifelse(grepl("ZDF", sendung), "ZDF", "ARD"), 
         frames = gsub("NANA", "0T", frames), 
         censored_frames = as.numeric(gsub("^[[:digit:]]*F|T", "", frames)), 
         censored_secs = res_sec * censored_frames)

x1

gsub("^[[:digit:]]*F|T", "", x$frames)

x1sum <- x1 %>% group_by(sendung) %>% summarize(sender = first(sender), 
                                                censored_secs = sum(censored_secs))
x1max <- x1 %>% group_by(sendung) %>% summarize(Prozent = max(prozent_num))

x1 %>% 
  ggplot(aes(x = sendung, y = prozent_num, group = sendung, fill = sendung)) + 
  # geom_boxplot(outlier.size = 0.5) + 
  geom_violin() + 
  # geom_point(data = x1max, aes(x = sendung, y = Prozent, color = sendung), 
             # shape = 18, size = 5) + 
  # geom_label(data = x1max, aes(x = sendung, y = Prozent, label = paste("max.\n", Prozent, "%"))) + 
  theme_minimal() + 
  labs(y = "Prozent der Sendung als Standbild", x = "Sendung") + 
  guides(color = "none", 
         fill = "none") + 
  scale_fill_manual(values = alpha(c("#3284be", "dodgerblue4", "darkorange", "darkgrey"), alpha = 0.7)) + 
  # facet_grid(sender~.)
  scale_color_manual(values = c("#3284be", "dodgerblue4", "darkorange", "darkgrey"))# + 
  
