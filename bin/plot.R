# Visualization
## Timecode
if(length(censored) != length(img))
  stop("Missing Frame?")
imgn <- 1:length(censored)
timecode <- seconds_to_period(imgn*res)

## Baue dataframe
df <- data.frame(
  imgn = imgn,
  Minute  = timecode,
  Zensiert = censored,
  Online = ifelse(censored, "Offline", "Online")
)
df$Online <- factor(df$Online, levels = c("Online", "Offline"), ordered = TRUE)

## Wann zensiert?
#http://stackoverflow.com/q/42427663/6549166
startZensur <- which(diff(!df$Zensiert)==-1) +1
startZensur <- df[startZensur,]


## Abbildung erstellen
colors <- c("dodgerblue", "orangered")

breite <- length(img)*res/60  # Länge der Sendung
ggplot(df, aes(y=2, imgn, color = Online, fill = Online))+
  # Pie Chart
  coord_polar(start = 0) +
  geom_col() +
  scale_color_manual(values= colors) +
  scale_fill_manual(values = colors) +
  geom_text(data = startZensur, aes(label = Minute),
            color="Gray20", nudge_y = 0.2) +
  
  # Label Start
  geom_vline(xintercept = 0, color= "Gray20") +  # TODO: Kosmetische korrektur. Start bei exact 12Uhr
  geom_text(aes(x = 0), label = "▶️", color="Gray20", nudge_y = 0.15,
            nudge_x =0.8, size =3) +
  
  # Label Zensiert
  geom_point(aes(x = 0, y = 0),
             color="white", size = 50, alpha = 0.5,
             show.legend = FALSE) +
  geom_text(aes(x = 0, y = 0),
            label = prozentZensiert, color="Black", size = 15,
            show.legend = FALSE) +
  
  # Theming
  theme_minimal() +
  theme(axis.title = element_blank(),
        axis.text = element_blank(),
        panel.grid = element_blank(),
        legend.position = "bottom",
        legend.title=element_blank()) +
  
  # Labels
  labs(title = msg[1])


## Rausspeichern
ggsave("heuteStatisik.png", width = 3, height = 3, scale = 2, dpi = 150)

### Bild Hintergrund mit Imagick hinzufügen
#http://unix.stackexchange.com/a/243545
if(grepl("h", sendung)){
  cmd <- "composite -blend 80 heuteStatisik.png ./extra/Hintergrund_ZDF.png heuteStatisik.png"
} else {
  cmd <- "composite -blend 80 heuteStatisik.png ./extra/Hintergrund_ARD.png heuteStatisik.png"
}
system(cmd)

## mediaPath für twitter
mediaPath <- "heuteStatisik.png"