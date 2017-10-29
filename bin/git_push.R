## git push Logfile
commit <- paste(sendung, date)
system("git stage Logfile.csv")
system("git stage heuteStatistik.png")
system(paste('git commit -m "', commit, '"'))
system("git push")