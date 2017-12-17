# Installation
Hier erfährst du wie du einen eigenen Knoten aufsetzt.

Zunächst müssen folgende Dependencies installiert sein:  
  **Linux** `sudo apt install ffmpeg libcurl4-openssl-dev imagemagick libmagick++-dev libtesseract-dev libleptonica-dev tesseract-ocr-eng tesseract-ocr-deu`
    
**R:** `install.packages(c("jpeg", "rvest", "ggplot2", "tibble", "lubridate", "stringr", "magick", "tesseract", "twitteR"), repos = "https://cran.rstudio.com")`



Dann kannst du das Repository klonen  
**Linux** `git clone git@github.com:georoen/heuteZensiert.git`

und bspw. die *heute 19Uhr* Nachrichten prozessieren:  
`Rscript --vanilla bin/heuteZensiert.R h19`



Anschließend werden mit [`CRONTAB`](https://wiki.ubuntuusers.de/Cron/) täglich die Nachrichten-Sendungen prozessiert.
```
# 50 19 * * * cd ~/heuteZensiert/ && nohup Rscript --vanilla bin/heuteZensiert.R h19 &
# 50 20 * * * cd ~/heuteZensiert/ && nohup Rscript --vanilla bin/heuteZensiert.R t20 &
# 50 23 * * *  cd ~/heuteZensiert/ && nohup Rscript --vanilla bin/heuteZensiert.R hjo &
```

Voilà - Wilkommen im Team!