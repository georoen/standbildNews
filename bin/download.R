#' Download Stream
#' aka: stream <- function(date, sendung, dateshift, msg)




#' Rveste URL vom RSS-Feed
rss <- function(url, dateshift, sendung) {
  # inspired by https://stackoverflow.com/questions/32127921/rvest-how-to-select-a-specific-css-node-by-id
  library(rvest)
  URLs <- read_html(url) %>%
    html_nodes("enclosure") %>%
    html_attr("url")
  URL <- URLs[[dateshift +1]]  # Wähle "Datum" (ungenau, eher RSS-Reihenfolge) aus
  # Lese tatsächliches Datum aus URL...
  URLdate <- regmatches(basename(URL), regexpr("\\d+", basename(URL)))
  # ... und korrigiere es im global enviroment
  format <- ifelse(sendung == "t20", "%Y%m%d", "%y%m%d")
  date <<- as.Date(URLdate, format)

  return(URL)
}




# Nachrichtensendung herunterladen
## Stream in Tempdir speichern
Temp <- ifelse(!dev,  # dev = TRUE um Frames zu archivieren
       paste0(tempdir(), "/", format(date, "%y%m%d"), "_", sendung, "/"),  # Tmp
       paste0(wd, "/archiv/", format(date, "%y%m%d"), sendung, "/"))  # Archive Mode

if(dir.exists(Temp))
  stop("Directory exists. Avoid Dublicates")
dir.create(Temp)
TempImg <- paste0(Temp, "/img%03d.jpg")


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
    } else if( mode == 3){
      # RSS !
      if(sendung == "h19"){
        URL <- rss("http://www.zdf.de/rss/podcast/video/zdf/nachrichten/heute-sendungen",
                   dateshift, sendung)
      } else if(sendung == "hjo") {
        URL <- rss("http://www.zdf.de/rss/podcast/video/zdf/nachrichten/heute-journal",
                   dateshift, sendung)
      }
    } else {
      stop(paste("mode", mode, "nicht bekannt!"))
    } # ENDE ZDF

    # ARD Tageschau 20Uhr
  } else if( sendung == "t20") {
    URL <- rss("https://www.tagesschau.de/export/video-podcast/tagesschau/",
               dateshift, sendung)

  }

  URL
}




# RSS kann anderes Datum haben. Doublecheck Logfile
Logfile.latest <- read.csv(file.path(wd, "Logfile.csv"), stringsAsFactors = FALSE)
if(sendung %in% Logfile.latest[which(as.character(date) == Logfile.latest[[1]]), 2])
  stop("Diese Sendung wurde schon prozessiert.")




## Download. Dauert ein paar Minuten...
URL <- compose_URL(date, sendung, mode = 3)
(cmd <- paste("ffmpeg -i", URL, "-vf", paste0("fps=1/",res), TempImg))
nokay <- try(system(cmd))

if(nokay){
  # Download hat nicht geklappt. Variere URL
  URL <- compose_URL(date, sendung, mode = 2)
  (cmd <- paste("ffmpeg -i", URL, "-vf", paste0("fps=1/",res), TempImg))
  nokay <- try(system(cmd))
}
if(nokay){
  # Download hat nicht geklappt. Variere URL
  URL <- compose_URL(date, sendung, mode = 1)
  (cmd <- paste("ffmpeg -i", URL, "-vf", paste0("fps=1/",res), TempImg))
  nokay <- try(system(cmd))
}

if(nokay){
  # Download hat immer noch nicht geklappt... Breche ab!
  msg <- c(header(sendung, date))
  (msg <- c(msg, "konnte nicht geladen werden."))
  #unlink(Temp, recursive = TRUE)
  # Twittern
  mediaPath <- NULL
  #source("extra/tweet.R")
  # Stop
  stop(paste("Streamfehler in", URL))
}


