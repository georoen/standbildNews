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
#' Rscript --vanilla heuteZensiert.R hjo `date --date="-2 day" +%Y%m%d`


setwd("~/Programmierung/heuteZensiert/")


# Packages
library(jpeg)
library(tidyverse)
library(lubridate)
library(stringr)
library(anytime)



# Parameter
## Manage Parameter. Vorbereitung für CRONTAB
# www.r-bloggers.com/passing-arguments-to-an-r-script-from-command-lines/
args = commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  ### Keine Argumente
  warning("Keine Argumente. Verwende default", call.=FALSE)
  sendung <- "h19"
  date <- Sys.Date()
  
} else if (length(args)==1) {
  ### Sendung angegeben. Datum fehlt
  sendung <- args[1]
  date <- Sys.Date()  # Heute
  
} else if (length(args)==2){
  ### Sendung und Datum angegenen
  sendung <- args[1]
  date <- anytime::anydate(args[2])
  if(is.na(date))
    stop("Argument 2 ist kein Datum. Siehe ?anytime")
}
### Checke ob Sendung zulässig
if(!sendung %in% c("h19", "hjo"))
  stop("Sendung weder h19 (ZDF 19Uhr Nachrichten) noch hjo (heute Journal")
sendung <- paste0("_", sendung)  # returns "_h19" or "_hjo"
### Komponierte Tweet [1]
header <- function(sendung, date){
  if(sendung == "_h19")
    sendung <- "ZDF Heute 19Uhr"
  if(sendung == "_hjo")
    sendung <- "ZDF Heute Journal"
  
  date <- format(date, format = "%d.%m.%Y")
  
  paste(sendung, "vom", date)
}
msg <- c(header(sendung, date))

## Zielbild
zielbild <- "heuteZensiert.jpg"
## Framerate in Sekunden
res <- 10
## Logfile
logfile <- "Logfile.csv"



# Nachrichtensendung herunterladen
## Paste0 URL
# heute 19 uhr 
# offiziell: https://downloadzdf-a.akamaihd.net/mp4/zdf/17/02/170225_hjo/1/170225_hjo_476k_p9v13.mp4
# mediathekview: https://rodlzdf-a.akamaihd.net/none/zdf/17/02/170213_h19/1/170213_h19_2328k_p35v13.mp4
URL <- paste0("https://downloadzdf-a.akamaihd.net/mp4/zdf/",
              format(date, "%y"), "/", format(date, "%m"), "/", 
              format(date, "%y%m%d"), sendung, "/1/", format(date, "%y%m%d"), 
              sendung, "_476k_p9v13.mp4")

## Tempdir
Temp <- tempdir()
dir.create(Temp)
TempImg <- paste0(Temp, "/img%03d.jpg")
## Download. Dauert ein paar Minuten...
cmd <- paste("ffmpeg -i", URL, "-vf", paste0("fps=1/",res), TempImg)
nokay <- try(system(cmd))
if(nokay){
  (msg <- c(msg, "Konnte nicht geladen werden"))
  stop(paste("Streamfehler in", URL))
}



# Suche Zielbild in Stream
## Zielbild laden
aim <- readJPEG(zielbild)
# raster <- as.raster(aim)
# par(ask=FALSE)
# plot(as.raster(aim))

## Liste Frames auf
img <- list.files(Temp, ".jpg$", full.names = TRUE)

## Image Differencing:
equalCensor <- function(frame, censor = aim){
  # Einfache Veränderungsdetection: Substrahiere Frame von Zielbild
  # Gibt den auf drei Stellen gerundeten Unterschied zurück.
  # usage: equalCensor(censor = aim, frame = img[15])
  
  frame <- readJPEG(frame)
  img.d <- censor - frame
  #plot(as.raster(abs(img.d)))
  #print(summary(img.d))
  round(mean(img.d),3) == 0
}
censored <- sapply(img, FUN = equalCensor, simplify = TRUE)

## Prozent zensiert
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

cat(paste0(output, "\n"), file = logfile, append = TRUE)



# Zensur? Twittere Statisik
if(!TRUE %in% censored){  # Gesamte Sendung online.
  (msg <- c(msg, "Super Sendung"))
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
         subtitle = msg[2],
         caption = "www.github.com/georoen/heuteZensiert")
  
  
  ## Rausspeichern
  ggsave("heuteStatisik.png", width = 3, height = 3, scale = 2, dpi = 150)
  
  ### Bild Hintergrund mit Imagick hinzufügen
  #http://unix.stackexchange.com/a/243545
  cmd <- "composite -blend 80 heuteStatisik.png ./extra/Hintergrund.png heuteStatisik.png"
  system(cmd)

}  # ENDE
unlink(Temp, recursive = TRUE)



# Twittern