#' Dieses R Skript untersucht die Sendungen ZDF Heute, ZDF Heute Journal und 
#' ARD Tagesschau nach Frames, welche nicht im Internet verfügbar sind. 
#' Diese Frames enthalten Nachrichten wie "Diese Bilder dürfen aus rechtlichen
#' Gründen nicht gezeigt werden."
#'
#' Ziel ist es datengratragene Krtik am ARD und ZDF zu üben, digitale wie 
#' analoge Rundfunksbeitrag-Zahler gleich zu behandeln.
#' Dafür sollen:
#' 1) Im Falle von Zensur Statistiken per Twitterbot verbreitet werden.
#' 2) Ein Datenarchiv für Medien- & Justizwissenschaftler erstellt werden.
#'
#' Contribution welcome. Helfe mit :-)
#'
#' Usage:
#' Rscript --vanilla bin/heuteZensiert.R hjo 1  # von vor einem Tag
#' Rscript --vanilla bin/heuteZensiert.R h19 `date +%Y%m%d`
#'
#' Variablen Lookup Tabelle:
#' | Variable | Erstellt in Skript | Beschreibung des Inhaltes                 | 
#' |:-------- |:------------------ |:----------------------------------------- |
#' | date     | heuteZensiert.R    | Datum der Ausgestrahlten Sendung          |
#' | dev      | heuteZensiert.R    | Entwicklungsmodus (TRUE/FALSE)            |
#' | s.name   | heuteZensiert.R    | Name der Sendung, Verwendung für Plot     |
#' | start    | heutezensiert.R    | Startzeit des Skriptes                    |
#' |  |  |  |
#' |  |  |  |
#' |  |  |  |
#' 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                                Preamble                                      #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#### Entwicklungsmodus ####
#' Im Entwicklungsmodus werden die extrahierten Bilder aus dem Sendungsstream
#' nicht gelöscht. Zusätzlich wird das errechnete Ergebnis nicht getwittert. 
#' Der Entwicklungsmodus wird aktiviert indem die Variable `dev` auf TRUE 
#' gesetzt wird. 
dev <- FALSE  # Devmode?

if (dev){
  dir.create("archiv")
}

#### Parameter ####
## Default
res <- 3  # Framerate in Sekunden
wd <- getwd()  # Helps sourcing code in bin/ 
Logfile <- file.path(wd, "Logfile.csv")  # Logfile

# Entfernen von bestehendem nohup Output
file.remove("nohup.out")
(start <- Sys.time())  # Start Time

#### Packages ####
library(jpeg)
library(ggplot2)
library(tibble)
library(lubridate)
library(stringr)
library(tesseract)
library(magick)
library(twitteR)
library(rvest)

#### Funktionen ####
## msg Header [1]
header <- function(sendung, date, sep = " vom "){
  if(grepl("h19", sendung))
    s.name <- "ZDF Heute 19Uhr"
  if(grepl("hjo", sendung))
    s.name <- "ZDF HeuteJournal"
  if(grepl("t20", sendung))
    s.name <- "ARD Tagesschau"
  if(grepl("tth", sendung))
    s.name <- "ARD Tagesthemen"
  
  date <- format(date, format = "%d.%m.%Y")
  
  paste(s.name, date, sep = sep)
}

#' Skriptpfad erhalten oder generieren. 
getScriptPath <- function(){
  # https://stackoverflow.com/a/24020199
  cmd.args <- commandArgs()
  m <- regexpr("(?<=^--file=).+", cmd.args, perl=TRUE)
  script.dir <- dirname(regmatches(cmd.args, m))
  if(length(script.dir) == 0) {
    return("bin")  #stop("can't determine script dir: please call the script with Rscript")
  }
  if(length(script.dir) > 1) {
    stop("can't determine script dir: more than one '--file' argument detected")
  }
  return(script.dir)
}
#' Angepasste version von `source`
source2 <- function(file, ...) {
  (file <- file.path(getScriptPath(), file))
  source(file, ...)
}


#### Argumente ####
# Übernahme der Argumente aus dem Rscript-Prozess (siehe [Install.md](../Install.md))
# www.r-bloggers.com/passing-arguments-to-an-r-script-from-command-lines/
# args <- list(sen = "hjo", date = Sys.Date())
# args <- list(sen = "h19", date = format(Sys.Date(), "%Y%m%d"))
args <- commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  ### Keine Argumente. Run Defaults = 19Uhr von date( <HEUTE> )
  warning("Keine Argumente. Verwende default", call.=FALSE)
  # sendung <- "t20"
  sendung <- "h19"
  date <- Sys.Date()
  dateshift <- 0
  
  # Wenn es heute noch vor 19 Uhr ist, wird der gestrige Tag angenommen, da 
  # heutiges Video noch nicht online. 
  if (lubridate::hour(Sys.time()) < 19){
    date <- date - 1
  }
  
} else if (length(args)==1) {
  ### Sendung angegeben. Datum fehlt
  sendung <- args[1]
  date <- Sys.Date()  # Heute
  dateshift <- 0
  
  # Wenn es heute noch vor 19 (20, 23) Uhr ist, wird der gestrige Tag angenommen, da 
  # heutiges Video noch nicht online.
  zeitDerSendung <- switch(sendung, 
                           h19 = 19, 
                           t20 = 20, 
                           hjo = 23, 
                           tth = 22)
  if (lubridate::hour(Sys.time()) < zeitDerSendung){
    date <- date - 1
  }

} else if (length(args)==2){
  ### Sendung und Datum angegenen
  sendung <- args[1]
  dateshift <- as.numeric(unlist(args[2]))
  date <- Sys.Date()-dateshift
  if(is.na(date)){
    stop("Argument 2 ist keine Zahl und kann nicht vom Datum abgezogen werden.")
  }
}

## Checke ob Sendung zulässig
if(!sendung %in% c("h19", "sendung_h19", "hjo", "sendung_hjo", "t20", "tth")){
  stop("Sendung nicht bekannt")
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                               Processing                                     #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#### Pull aktuelles Repo vom github ####
source2("git_pull.R")

#### Download ####
source2("download.R", chdir = TRUE)

#### Texterkennung ####
# source2("mth_Classic.R")
source2("mth_OCR.R", chdir = TRUE)

# Lösche Bilder wenn nicht im Entwicklungsmodus
if(!dev){ 
  unlink(Temp, recursive = TRUE)
} 

#### Evaluation ####
# Ist die überprüfte Nachrichtensendung vollständig online verfügbar?
if(!TRUE %in% censored){  
  # Gesamte Sendung online verfügbar
  (msg <- paste(c(header(sendung, date)), "vollständig online."))
  mediaPath <- NULL

}else{  # Unvollständig. Teile der Nachrichtensendung fehlen
  lubridate2string <- function(x){
    gsub("M ", " Minuten ",
         gsub("S$", " Sekunden", as.period(x)))
  }
  (msg <- c(paste0(lubridate2string(absolutZensiert), " von ",
                   lubridate2string(absoluteDauer), " der ", 
                   c(header(sendung, date, " Sendung vom ")), " ",
                   "wurden nicht im Internet gezeigt (", prozentZensiert, ")")))
  # Erstelle Abbildung
  source2("plot.R")
} 

#### Twittern ####
if(!dev){
  source2("tweet.R")
}

#### push Logfile auf Github ####
source2("git_push.R")

#### End Time ####
Sys.time() - start
