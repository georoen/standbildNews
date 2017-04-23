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

# Function
## Logfile
Logfile <- "Logfile.csv"
catlog <- function(msg, file = Logfile) {
  cat(msg, file, append = TRUE)
  message(msg)
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
  sendung <- "t20"
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

### Komponierte Tweet [1]
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
msg <- c(header(sendung, date))



# Nachrichtensendung herunterladen
## Stream in Tempdir speichern
Temp <- paste0(tempdir(), "/", format(date, "%y%m%d"), "_", sendung, "/")
#Temp <- paste0("archiv/", format(date, "%y%m%d"), sendung, "/")
if(dir.exists(Temp))
  stop("Directory exists. Avoid Dublicates")
dir.create(Temp)
TempImg <- paste0(Temp, "/img%03d.jpg")

## Framerate in Sekunden
res <- 3

## Paste0 URL
# ZDF
#' heute 19 Uhr 
#' mediathekview:  https://rodlzdf-a.akamaihd.net/none/zdf/17/02/170213_h19/1/170213_h19_2328k_p35v13.mp4  #h19
#' 7.3.17:         http://download.zdf.de/mp4/zdf/17/03/170307_h19/1/170307_h19_3296k_p15v13.mp4
#' offiziell:      https://downloadzdf-a.akamaihd.net/mp4/zdf/17/02/170225_hjo/1/170225_hjo_476k_p9v13.mp4
#' 4.3.17:         https://downloadzdf-a.akamaihd.net/mp4/zdf/17/03/170304_h19/1/170304_h19_476k_p9v13.mp4  #h19
#' 2.3.17: ERROR!  https://downloadzdf-a.akamaihd.net/mp4/zdf/17/03/170302_sendung_h19/1/170302_sendung_h19_476k_p9v13.mp4  #h19
# 
# ARD
#' tagesschau 20Uhr
#' 23.4.17: http://download.media.tagesschau.de/video/2017/0423/TV-20170423-2033-4601.h264.mp4
#' 22.4.17: http://download.media.tagesschau.de/video/2017/0422/TV-20170422-2131-2301.h264.mp4
compose_URL <- function(date, sendung, mode) {
  # ZDF
  if(sendung %in% c("h19", "sendung_h19", "hjo", "sendung_hjo")){
    if(mode == 1){
      sendung2 <- paste0("_sendung_", sendung)
      URL <- paste0("https://downloadzdf-a.akamaihd.net/mp4/zdf/",
                    format(date, "%y"), "/", format(date, "%m"), "/", 
                    format(date, "%y%m%d"), sendung2, "/1/", format(date, "%y%m%d"), 
                    sendung2, "_476k_p9v13.mp4")
    } else if( mode == 2){
      # Veraltet...?
      URL <- paste0("https://downloadzdf-a.akamaihd.net/mp4/zdf/",
                    format(date, "%y"), "/", format(date, "%m"), "/", 
                    format(date, "%y%m%d"), "_", sendung, "/1/", 
                    format(date, "%y%m%d"), "_",sendung, "_476k_p9v13.mp4")
    } else {
      stop(paste("mode", mode, "nicht bekannt!"))
    } # ENDE ZDF
  
  # ARD  
  } else if( sendung == "t20") {
    # Rveste URL vom RSS-Feed
    library(rvest)
    URLhtml <- "https://www.tagesschau.de/export/video-podcast/tagesschau/"
    URLs <- read_html(URLhtml) %>%
      html_nodes("enclosure") %>% 
      html_attr("url")
    URL <- URLs[[dateshift +1]]  # Wähle "Datum" (ungenau, eher RSS-Reihenfolge) aus
  }
  
  
  URL
}

## Download. Dauert ein paar Minuten...
URL <- compose_URL(date, sendung, mode = 1)
(cmd <- paste("ffmpeg -i", URL, "-vf", paste0("fps=1/",res), TempImg))
nokay <- try(system(cmd))

if(nokay){
  # Download hat nicht geklappt. Variere URL
  URL <- compose_URL(date, sendung, mode = 2)
  (cmd <- paste("ffmpeg -i", URL, "-vf", paste0("fps=1/",res), TempImg))
  nokay <- try(system(cmd))
}

if(nokay){
  # Download hat immer noch nicht geklappt... Breche ab!
  (msg <- c(msg, "Konnte nicht geladen werden"))
  unlink(Temp, recursive = TRUE)
  stop(paste("Streamfehler in", URL))
}



# Suche Zielbild in Stream

## Indezierung von Bildern
# Mean dient dazu passendes Bild schnell zu finden
# auch andere Methoden sind denkbar: median(), sd()
# ... sollen zukünftig erlauben auch komplexere sachen zu rechnen, zB 4*4 raster skalierung ähnlich OCR
readLib <- function(zielbild, method = mean, digits = 4, ...) {
  ## Bild laden
  aim <- readJPEG(zielbild)
  ## Methode anwenden
  round(method(aim, ...), digits)
}

## Indeziere Zielbilder
zielbilder <- list.files("lib/", pattern = ".jpg$", full.names = TRUE)
zielbilder.mean <- sapply(zielbilder, readLib)


## Indeziere Heute Frames
img <- list.files(Temp , pattern =  ".jpg$", full.names = TRUE, recursive = TRUE)
img.mean <- sapply(img, readLib)

## Auswertung
censored <- img.mean %in% zielbilder.mean
prozentZensiert <- length(censored[which(censored)])/length(censored)
prozentZensiert <- paste0(round(prozentZensiert, 3) * 100, "%")



# Speichere Ergebniss
encodeCensored <- function(censored){
  #' Komprimiert die booleansche Zeitreihe
  #' Input `censored` booleanscher Vector. TRUE (1) sind zensierte Frames, FALSE (0) sind online verfügbar
  #' bspw. 000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111000000011110000000000000
  #' entspricht 88F5T7F4T13F (88*FALSE 5*TRUE 7*FALSE 4*TRUE 13*FALSE)
  censored_out <- c(which(diff(censored)==1), which(diff(censored)==-1), 
                    length(censored))
  censored_out <- as.numeric(levels(ordered(censored_out)))

  censored_comp <- data_frame(comp = c(censored_out[1], diff(censored_out)),
                              key = ifelse(censored[censored_out], "T", "F"))
  censored_comp <- sapply(c(1:length(censored_comp)), FUN = function(i){
    paste0(censored_comp[i,], collapse = "")})
  
  paste0(censored_comp, collapse = "")
}
decodeCensored <- function(censoredInformation){
  # reverse encodeCensored()
  censored_comp.key <- unlist(str_extract_all(censoredInformation, "\\D+"))  # http://stackoverflow.com/questions/42476058/strsplit-returns-invisible-element
  censored_comp.key <- ifelse(censored_comp.key == "T", TRUE, FALSE)
  censored_comp.comp <- as.numeric(unlist(strsplit(censoredInformation, "[T|F]")))
  # censored_comp <- data_frame(comp = censored_comp.comp,
  #                             key = censored_comp.key)
  unlist(sapply(c(1:length(censored_comp.comp)), FUN = function(i){
    rep(censored_comp.key[i], censored_comp.comp[i])}))
}

censoredInformation <- encodeCensored(censored)
#test <- decodeCensored(censoredInformation)

output <- paste(date, sendung, prozentZensiert,  # Einfache Infos
                censoredInformation,  # encoded censoredInformation
                paste0("1/",res), URL,  # Metadaten 
                sep = ";")  # read.csv2

cat(paste0(output, "\n"), file = Logfile, append = TRUE)
#catlog(paste0(output, "\n"))



# Zensur? Twittere Statisik
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
    Online = ifelse(censored, "Nein!", "Ja")
    
  )
  
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
    geom_vline(xintercept = 0.5, color= "Gray20") +  # TODO: Kosmetische korrektur. Start bei exact 12Uhr
    geom_text(aes(x = 0), 
              label = "Start:", color="Gray20", nudge_y = 0.15, nudge_x = 4) +
    
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
          legend.position = "bottom") +
    
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
#unlink(Temp, recursive = TRUE)



# Twittern
#source("extra/tweet.R")
