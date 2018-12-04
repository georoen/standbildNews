library(dplyr)
library(lubridate)
library(ggplot2)
library(ggridges)

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
         censored_secs = res_sec * censored_frames, 
         sendung = ordered(sendung, c("ZDF Heute 19 Uhr", "ZDF Heute Journal","ARD Tagesschau", "ARD Tagesthemen")))

x1

x1sum <- x1 %>% group_by(sendung) %>% summarize(sender = first(sender), 
                                                censored_secs = sum(censored_secs))
x1max <- x1 %>% group_by(sendung) %>% summarize(Prozent = max(prozent_num))

# Plot 1: Prozent Treppchen
x1mean <- x1 %>% group_by(sender, sendung) %>% summarize(Prozent = mean(prozent_num))
ggplot(x1mean, aes(sendung, Prozent)) +
  geom_col() +
  geom_text(aes(label = round(Prozent,1)), nudge_y = 0.25, size = 20) +
  scale_fill_manual(values = alpha(c("darkorange", "darkgrey", "#3284be", "dodgerblue4"), alpha = 0.7)) +
  facet_wrap(~sender, scales = "free_x")

# Plot 2: JOY heißt jetzt ggridges
x1 %>% 
  ggplot(aes(y = sendung, x = prozent_num, group = sendung, fill = sendung)) + 
  # geom_boxplot(outlier.size = 0.5) + 
  # geom_violin() + 
  geom_density_ridges2(color = "lightgrey", scale = 0.5) + 
  # geom_point(data = x1max, aes(x = sendung, y = Prozent, color = sendung), 
             # shape = 18, size = 5) + 
  # geom_label(data = x1max, aes(x = sendung, y = Prozent, label = paste("max.\n", Prozent, "%"))) + 
  theme_minimal() + 
  labs(x = "Standbild pro Sendung", y = element_blank()) + 
  guides(color = "none", 
         fill = "none") + 
  scale_fill_manual(values = alpha(c("darkorange", "darkgrey", "#3284be", "dodgerblue4"), alpha = 0.7)) + 
  scale_x_continuous(limits = c(0,40)) #+ 
  # theme(panel.grid.major.y = element_blank())
  # scale_y_discrete(breaks = NULL)
  
