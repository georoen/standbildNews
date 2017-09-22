#' Dieses R Skript untersucht das ZDF Heute Journal nach Frames,
#' welche nicht im Internet verfügbar sind.
#'
#' Ziel ist es datengratragene Krtik am ZDF zu üben, digitalen wie analogen
#' Rundfunksbeitrag-Zahler gleich zu behandeln.
#' Dafür sollen:
#' 1) Im Falle von Zensur Statistiken per Twitterbot verbreitet werden.
#' 2) Ein Datenarchiv für Medien-&Justizwissenschaftler erstellt werden.
#'
#' Contribution welcome. Helfe mit :-)
#'
#' Usage:
#' Rscript --vanilla heuteZensiert.R h19 `date +%Y%m%d`
#' Rscript --vanilla heuteZensiert.R hjo `date --date="-1 day" +%Y%m%d`



# Packages
library(jpeg)
library(ggplot2)
library(tibble)
library(lubridate)
library(stringr)
#library(heuteZensiert)

dev <- FALSE  # Devmode?

# Function
## Logfile
Logfile <- "Logfile.csv"
catlog <- function(msg, file = Logfile) {
  cat(msg, file, append = TRUE)
  message(msg)
}
## msg Header [1]
header <- function(sendung, date){
  if(grepl("h19", sendung))
    s.name <- "ZDF Heute 19Uhr"
  if(grepl("hjo", sendung))
    s.name <- "ZDF Heute Journal"
  if(grepl("t20", sendung))
    s.name <- "ARD Tageschau"

  date <- format(date, format = "%d.%m.%Y")

  paste(s.name, "vom", date)
}




# Parameter
## Manage Parameter. Vorbereitung für CRONTAB
# www.r-bloggers.com/passing-arguments-to-an-r-script-from-command-lines/
# args <- list(sen = "hjo", date = Sys.Date())
# args <- list(sen = "h19", date = format(Sys.Date(), "%Y%m%d"))
args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  ### Keine Argumente. Run Defaults = 19Uhr von date( <HEUTE> )
  warning("Keine Argumente. Verwende default", call.=FALSE)
  # sendung <- "t20"
  sendung <- "h19"
  date <- Sys.Date()
  dateshift <- 0

} else if (length(args)==1) {
  ### Sendung angegeben. Datum fehlt
  sendung <- args[1]
  date <- Sys.Date()  # Heute
  dateshift <- 0

} else if (length(args)==2){
  ### Sendung und Datum angegenen
  sendung <- args[1]
  dateshift <- as.numeric(unlist(args[2]))
  if(is.na(date))
    stop("Argument 2 ist keine Zahl und kann nicht vom Datum abgezogen werden.")
  date <- Sys.Date()-dateshift
}
### Checke ob Sendung zulässig
if(!sendung %in% c("h19", "sendung_h19", "hjo", "sendung_hjo", "t20"))
  stop("Sendung nicht bekannt")

## Framerate in Sekunden
res <- 30




# Download
source("download.R")




# Suche Zielbild in Stream
# source("mth_Classic.R")
source("mth_OCR.R")




# Zensur? Twittere Statisik
msg <- c(header(sendung, date))
if(!TRUE %in% censored){  # Gesamte Sendung online.
  (msg <- paste(msg, "vollständig online."))
  mediaPath <- NULL
  # ENDE

}else{  # Teile Nachrichtensendung fehlen
  (msg <- c(msg, paste(prozentZensiert,
                           "der Sendung wurden nicht im Internet gezeigt.")))



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
    coord_polar(start = -0.1) +
    geom_col() +
    scale_color_manual(values= colors) +
    scale_fill_manual(values = colors) +
    geom_text(data = startZensur, aes(label = Minute),
              color="Gray20", nudge_y = 0.2) +

    # Label Start
    geom_vline(xintercept = 0.5, color= "Gray20") +  # TODO: Kosmetische korrektur. Start bei exact 12Uhr
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
    labs(title = msg[1],
         subtitle = msg[2])


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

}  # ENDE
if(!dev)
  unlink(Temp, recursive = TRUE)



# Twittern
if(!dev)
  source("extra/tweet.R")
