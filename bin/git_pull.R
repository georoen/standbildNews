## git pull Logfile
system("git pull")
Logfile.latest <- read.csv("Logfile.csv", stringsAsFactors = FALSE)
if(!opt_dev && sendung %in% Logfile.latest[which(as.character(date) == Logfile.latest[[1]]), 2]){
  stop("Diese Sendung wurde schon prozessiert.")
}



