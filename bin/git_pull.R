## git_pull
system("git pull")
log <- unlist(tail(read.csv("Logfile.csv", stringsAsFactors = FALSE), 1))
if(date == log[1] && sendung == log[2])
    stop("Diese Sendung wurde schon prozessiert.")