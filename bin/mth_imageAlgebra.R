library(jpeg)

# select corresponding reference frame
# TODO check if tagesthemen and heute journal need separate frames
if(sendung %in% c("h19", "hjo")){
  frameIMG <- readJPEG("extra/zdf_frame.jpg")
} else {
  frameIMG <- readJPEG("extra/ard_frame.jpg")
}

# list all downloaded frames
# fls <- list.files(Temp, pattern = ".jpg$", full.names = TRUE)
img <- list.files(Temp , pattern =  ".jpg$", full.names = TRUE, recursive = TRUE)  # mth_OCR.R:39

# calculate array difference between reference and all frames
diffs <- sapply(img, function(x, y = frameIMG){
  diff <- readJPEG(x) - y
  return(mean(abs(diff)))
})
# q90 <- sapply(img, function(x, y = frameIMG){
#   diff <- readJPEG(x) - y
#   return(quantile(abs(diff), 0.9))
# })
# hist(diffs)
# hist(q90)

# identify freeze frames
censored <- diffs < 0.05
absoluteDauer <- dminutes(length(img)*res/60)
prozentZensiert <- length(censored[which(censored)])/length(censored)
absolutZensiert <- absoluteDauer * prozentZensiert
prozentZensiert <- paste0(round(prozentZensiert, 3) * 100, "%")  # Pastable String
prozentOnline <- paste0(round(1-prozentZensiert, 3) * 100, "%")  # Pastable String

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




