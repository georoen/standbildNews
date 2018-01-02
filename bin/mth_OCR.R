## OCR
# library(tesseract)
# library(magick)
zdf_zensur <- function(img) {
  #' Gezielte OCR suche nach Zensur
  img <- image_read(img) %>%
    image_crop("340x200+620+220") %>%
    image_quantize(max = 2, colorspace = 'gray')
  rtn <- ocr(img, engine = tesseract("deu"))
  # check
  if(FALSE %in% grepl("rechtlichen Gründen", rtn))
    return("")
  # Minor OCR corrections
  rtn <- gsub("W-Bilder", "TV-Bilder", rtn)
  rtn <- gsub("Im", "im", rtn)
  rtn <- gsub("\n", " ", rtn)
  rtn <- gsub("  ", "", rtn)
  rtn
}

ard_zensur <- function(img) {
  img <- image_read(img) %>%
    image_crop("200x60+60+55") %>%
    image_resize("800x")
  rtn <- ocr(img, engine = tesseract("deu"))
  # check
  if(FALSE %in% grepl("Kurze Unterbrechung", rtn))
    return("")
  # Minor OCR corrections
  rtn <- gsub("\n", " ", rtn)
  rtn <- gsub("  ", "", rtn)
  rtn
}
# Wähle Sendung
ocr_zensur <- ifelse(sendung %in% c("t20", "tth"), ard_zensur, zdf_zensur)

## Indeziere Heute Frames
img <- list.files(Temp , pattern =  ".jpg$", full.names = TRUE, recursive = TRUE)
absoluteDauer <- dminutes(length(img)*res/60)

## OCR
img.mean <- sapply(img, ocr_zensur)

## Auswertung
if (sendung %in% c("t20", "tth")) { # rechtliche Gründe ist nicht immer korrekt erkannt (z.B. tth 2017-12-17)
  censored <- grepl("Kurze Unterbrechung", img.mean)
} else {
  censored <- grepl("rechtlichen Gründen", img.mean)
}
prozentZensiert <- length(censored[which(censored)])/length(censored)
absolutZensiert <- absoluteDauer * prozentZensiert
prozentZensiert <- paste0(round(prozentZensiert, 3) * 100, "%")  # Pastable String


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
                sep = ",")  # read.csv

cat(paste0(output, "\n"), file = Logfile, append = TRUE)


