## git push Logfile
commit <- paste(sendung, date)
system("git add Logfile.csv")
system("git add heuteStatistik.png")
system(paste('git commit -m "', commit, '"'))
system("git push")