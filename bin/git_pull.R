## git pull Logfile
system("git pull")
Logfile.latest <- unlist(tail(read.csv("Logfile.csv", stringsAsFactors = FALSE), 1))
if(date == Logfile.latest[1] && sendung == Logfile.latest[2])
    stop("Diese Sendung wurde schon prozessiert.")