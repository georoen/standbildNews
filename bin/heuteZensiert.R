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
# Rscript --vanilla bin/heuteZensiert.R h19 `date +%Y%m%d`
#' Rscript --vanilla bin/heuteZensiert.R hjo `date --date="-1 day" +%Y%m%d`



dev <- FALSE  # Devmode?
file.remove("nohup.out")
(start <- Sys.time())  # Start Time


# Packages
library(jpeg)
library(ggplot2)
library(tibble)
library(lubridate)
library(stringr)
library(tesseract)
library(magick)
library(twitteR)




# Funktionen
## msg Header [1]
header <- function(sendung, date, sep = " vom "){
  if(grepl("h19", sendung))
    s.name <- "ZDF Heute 19Uhr"
  if(grepl("hjo", sendung))
    s.name <- "ZDF Heute Journal"
  if(grepl("t20", sendung))
    s.name <- "ARD Tageschau"
  
  date <- format(date, format = "%d.%m.%Y")
  
  paste(s.name, date, sep = sep)
}
#' source files located in bin directory with…
getScriptPath <- function(){
  # https://stackoverflow.com/a/24020199
  cmd.args <- commandArgs()
  m <- regexpr("(?<=^--file=).+", cmd.args, perl=TRUE)
  script.dir <- dirname(regmatches(cmd.args, m))
  if(length(script.dir) == 0) return("bin")  #stop("can't determine script dir: please call the script with Rscript")
  if(length(script.dir) > 1) stop("can't determine script dir: more than one '--file' argument detected")
  return(script.dir)
}
#' and…
source2 <- function(file, ...) {
  (file <- file.path(getScriptPath(), file))
  source(file, ...)
}




# Parameter
## Default
res <- 3  # Framerate in Sekunden
wd <- getwd()  # Helps sourcing code in bin/ 
Logfile <- file.path(wd, "Logfile.csv")  # Logfile

## Argumente
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

## Checke ob Sendung zulässig
if(!sendung %in% c("h19", "sendung_h19", "hjo", "sendung_hjo", "t20"))
  stop("Sendung nicht bekannt")



# Pull repo from github
source2("git_pull.R")

# Download
source2("download.R", chdir = TRUE)

# Processing...
# source2("mth_Classic.R")
source2("mth_OCR.R", chdir = TRUE)

if(!dev)  # Lösche Bilder
  unlink(Temp, recursive = TRUE)




# Evaluation
msg <- c(header(sendung, date))
if(!TRUE %in% censored){  # Gesamte Sendung online.
  (msg <- paste(msg, "vollständig online."))
  mediaPath <- NULL

}else{  # Unvollständig. Teile der Nachrichtensendung fehlen
  (msg <- c(msg, paste(prozentZensiert,
                           "der Sendung wurden nicht im Internet gezeigt.")))
  # Erstelle Abbildung
  source2("plot.R")
} 




# Twittern
if(!dev)
  source2("tweet.R")




# push Logfile auf Github
source2("git_push.R")




# End Time
Sys.time() - start
