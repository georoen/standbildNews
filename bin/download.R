#' Download Stream


#### URL Generieren ####
# ARD
#' tagesschau 20Uhr
#' 23.4.17: http://download.media.tagesschau.de/video/2017/0423/TV-20170423-2033-4601.h264.mp4
#' 22.4.17: http://download.media.tagesschau.de/video/2017/0422/TV-20170422-2131-2301.h264.mp4
#' 
#' BR
#' - Links seit in neuer Mediathek (veröffentlicht auf Rundfunkmesse Oktober 2017) z.B. 
#' https://www.br.de/mediathek/video/rundschau-1830-uhr-sendung-vom-20102017-av:59afea204894ee001264f9c3
#' - Jedoch änderung am Token nciht möglich. Daher weitersuchen
#' - RSS (noch) nicht verfügbar, andere TV-Podcasts: 
#' http://www.br-online.de/podcast/tv/mp3-download-podcast-uebersicht-bayerischesfernsehen.shtml
#' - Hier alle Rundschau Sendungen gesammelt: https://www.br.de/mediathek/sendung/rundschau-av:584f4c183b467900117bf25f
#' auch hier führt die Änderung des av:... tokens zu fehlern. 
#' 
# ZDF
#' heute 19 Uhr
#' mediathekviewweb:  https://mediathekviewweb.de/#query=ZDF heute 19 Sendung vom
#' 7.3.17:         https://rodlzdf-a.akamaihd.net/none/zdf/17/02/170213_h19/1/170213_h19_2328k_p35v13.mp4  #h19
#' 7.3.17:         http://download.zdf.de/mp4/zdf/17/03/170307_h19/1/170307_h19_3296k_p15v13.mp4
#' offiziell:      https://downloadzdf-a.akamaihd.net/mp4/zdf/17/02/170225_hjo/1/170225_hjo_476k_p9v13.mp4
#' 4.3.17:         https://downloadzdf-a.akamaihd.net/mp4/zdf/17/03/170304_h19/1/170304_h19_476k_p9v13.mp4  #h19
#' 2.3.17: ERROR!  https://downloadzdf-a.akamaihd.net/mp4/zdf/17/03/170302_sendung_h19/1/170302_sendung_h19_476k_p9v13.mp4  #h19
#' 25.10.17:       https://downloadzdf-a.akamaihd.net/mp4/zdf/17/10/171025_sendung_h19/2/171025_sendung_h19_476k_p9v13.mp4  # h19
#' 25.10.17:       https://downloadzdf-a.akamaihd.net/mp4/zdf/17/10/171025_sendung_h19/2/171025_sendung_h19_1496k_p13v13.mp4  # h19 med. resolution for OCR
#' 28.10.17:       https://rodlzdf-a.akamaihd.net/none/zdf/17/10/171028_sendung_19/2/171028_sendung_19_2328k_p35v13.mp4  # h19. sendung <- "19"
#' 31.10.17:       https://rodlzdf-a.akamaihd.net/none/zdf/17/10/171031_h19/2/171031_h19_2328k_p35v13.mp4  # h19 via mediathekview
compose_URL.ard <- function(date, sendung, ...) {
  #' ARD Tagesschau 20Uhr via RSS
  #' ARD Tagesthemen via RSS
  #' @param sendung ist die Sendung (t20 oder tth)
  #' @param ... Es (noch keine) weiteren Argumente. Doch so wird hiermit der
  #' Syntax von ARD und ZDF wrappern homogenisiert. Spart Argument-Errors.
  #' @import rvest
  if (sendung == "t20"){
    RSS <- read_html("https://www.tagesschau.de/export/video-podcast/tagesschau/") %>%
      html_nodes("item")
  }
  if (sendung == "tth"){
    RSS <- read_html("https://www.tagesschau.de/export/video-podcast/tagesthemen/") %>%
      html_nodes("item")
  }
  
  # Datum
  RSS.date <- RSS %>% 
    html_node("title") %>% 
    html_text()
  RSS.date <- as.Date(sub(" - .*", "", RSS.date), format = "%d.%m.%Y")
  # Filter URL
  URL <- RSS[which(RSS.date == date)] %>%
    html_node("enclosure") %>%
    html_attr("url")
  
  as.character(URL)
}

compose_URL.zdf <- function(date, sendung) {
  #' Generiere URL für ZDF Nachrichten
  #' Diese haben zwar eine gewisse Struktur, sind aber leider etwas
  #' unsystematisch. Geordnet nach Wahrscheinlichkeit.
  paste_ZDF <- function(date, sendung,
                        server = "https://downloadzdf-a.akamaihd.net/mp4/zdf/",
                        video = "_476k_p9v13.mp4",
                        seed = "/2/") {
    paste0(server,
           format(date, "%y"), "/", format(date, "%m"), "/",
           format(date, "%y%m%d"), sendung, seed, format(date, "%y%m%d"),
           sendung, video)
  }
  
  #' URL Muster hjo vom 9.12.2019
  #' https://downloadzdf-a.akamaihd.net/mp4/zdf/19/12/191209_sendung_hjo/2/191209_sendung_hjo_808k_p11v15.mp4
  URL <- paste_ZDF(date,paste0("_sendung_", sendung), seed = "/2/", video = "_808k_p11v15.mp4")
  if(!httr::http_error(URL)) {
    return(URL)
  }
  
  #' URL-Muster vom 9.12.2019
  #' https://downloadzdf-a.akamaihd.net/mp4/zdf/19/12/191209_sendung_h19/3/191209_sendung_h19_808k_p11v15.mp4
  URL <- paste_ZDF(date,paste0("_sendung_", sendung), seed = "/3/", video = "_808k_p11v15.mp4")
  if(!httr::http_error(URL)) {
    return(URL)
  }
  
  #' URL-Muster vom 7.12.2019
  #' https://downloadzdf-a.akamaihd.net/mp4/zdf/19/12/191207_sendung_h19/4/191207_sendung_h19_808k_p11v15.mp4
  URL <- paste_ZDF(date,paste0("_sendung_", sendung), seed = "/4/", video = "_808k_p11v15.mp4")
  if(!httr::http_error(URL)) {
    return(URL)
  }
  
  #' URL-Muster von 14.6.2018  #TODO: Achtung, hier fehlt noch ein entsprechendes frameIMG, da WM Eröffnungsspiel gezeigt wurde :-)
  #' https://downloadzdf-a.akamaihd.net/mp4/zdf/18/06/180614_sendung_h19/2/180614_sendung_h19_776k_p11v14.mp4
  URL <- paste_ZDF(date,paste0("_sendung_", sendung), video = "_776k_p11v14.mp4")
  if(!httr::http_error(URL)) {
    return(URL)
  }
  URL <- paste_ZDF(date,paste0("_sendung_", sendung), seed = "/1/", video = "_776k_p11v14.mp4")
  if(!httr::http_error(URL)) {
    return(URL)
  }
  
  #' URL-Muster von 12.6.2018
  #' https://downloadzdf-a.akamaihd.net/mp4/zdf/18/06/180612_sendung_h19/2/180612_sendung_h19_476k_p9v14.mp4
  URL <- paste_ZDF(date,paste0("_sendung_", sendung), video = "_476k_p9v14.mp4")
  if(!httr::http_error(URL)) {
    return(URL)
  }

  #' URL-Muster von 25.10.2017
  #' https://rodlzdf-a.akamaihd.net/none/zdf/17/10/171028_sendung_19/2/171028_sendung_19_2328k_p35v13.mp4
  URL <- paste_ZDF(date,paste0("_sendung_", sendung))
  if(!httr::http_error(URL)) {
    return(URL)
  }
  
  #' URL-Muster von mediathekview 31.10.2017
  #' https://rodlzdf-a.akamaihd.net/none/zdf/17/10/171031_h19/2/171031_h19_2328k_p35v13.mp4
  URL <- paste_ZDF(date, paste0("_", sendung))
  if(!httr::http_error(URL)) {
    return(URL)
  }
  
  #' HeuteJournal oft auf Seed 1
  #' https://rodlzdf-a.akamaihd.net/none/zdf/17/10/171031_sendung_hjo/1/171031_sendung_hjo_2328k_p35v13.mp4
  URL <- paste_ZDF(date, paste0("_sendung_", sendung), seed = "/1/")
  if(!httr::http_error(URL)) {
    return(URL)
  }
  
  NULL
}


compose_URL <- function(date, sendung) {
  # Get URL
  if(sendung %in% c("h19", "sendung_h19", "hjo", "sendung_hjo")){
    # ZDF
    URL <- compose_URL.zdf(date, sendung)
  } else if(sendung %in% c("t20", "tth")) {
    # ARD
    URL <- (compose_URL.ard(date, sendung))
  }
  print(URL)  # Print URL to console - verbosity
  
  # Test it
  if(!is.null(URL) && !httr::http_error(URL)) {
    return(URL)
  }
  
  ifelse(dev, NA, stop ("Kann die gesuchte Sendung zu diesem Datum nicht finden!"))
}

URL <- compose_URL(date, sendung)  # 28.10.2017

#### Temp Directory für Frames ####
## Stream in Tempdir speichern
Temp <- ifelse(!dev,  # dev = TRUE um Frames zu archivieren
               paste0(tempdir(), "/", format(date, "%y%m%d"), "_", sendung, "/"),  # Tmp
               paste0(wd, "/archiv/", format(date, "%y%m%d"), sendung, "/"))  # Archive Mode

if(dir.exists(Temp)){
  message("Directory exists. Skipping Download")

} else {
  ## New Folder
  dir.create(Temp)
  TempImg <- paste0(Temp, "img%04d.jpg")
  
  #### Download ####
  (cmd <- paste("ffmpeg -i", URL, "-vf", paste0("fps=1/",res), TempImg))
  nokay <- try(system(cmd))
  
  
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
}   

