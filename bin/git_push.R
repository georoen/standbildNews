## git push Logfile
commit <- paste(sendung, date)
system("git add Logfile.csv")
system(paste('git commit -m "', commit, '"'))
system("git push")