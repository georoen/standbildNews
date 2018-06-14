# Installation
Hier erfährst du wie du einen eigenen Knoten zu unserem dezentralen Netzwerk hinzufügen kannst. Benötigt werden lediglich ein Linux Computer (z.B. Raspberry Pi 3), ein paar Packages, dieses Repository und einen gut getimeten Cronjob.

## Packages
Zunächst müssen folgende Dependencies / Packages installiert werden:  
  **Linux:** `sudo apt install r-base ffmpeg libcurl4-openssl-dev imagemagick libmagick++-dev libtesseract-dev libleptonica-dev tesseract-ocr-eng tesseract-ocr-deu`
    
**R:** `install.packages(c("jpeg", "rvest", "ggplot2", "tibble", "lubridate", "stringr", "magick", "tesseract", "twitteR"), repos = "https://cran.rstudio.com")`


## heuteZensiert herunterladen & ausprobieren
Dann kannst du das Repository klonen  
**Linux:** `git clone git@github.com:georoen/heuteZensiert.git`

und bspw. die *heute 19Uhr* Nachrichten prozessieren:  
`Rscript --vanilla bin/heuteZensiert.R h19`


## Zeitschaltung
Anschließend werden mit [`CRONTAB`](https://wiki.ubuntuusers.de/Cron/) täglich alle vier Nachrichten-Sendungen prozessiert.
```
0 20 * * * cd ~/heuteZensiert/ && nohup Rscript --vanilla bin/heuteZensiert.R h19 &
0 21 * * * cd ~/heuteZensiert/ && nohup Rscript --vanilla bin/heuteZensiert.R t20 &
0 22 * * *  cd ~/heuteZensiert/ && nohup Rscript --vanilla bin/heuteZensiert.R tth &
0 23 * * *  cd ~/heuteZensiert/ && nohup Rscript --vanilla bin/heuteZensiert.R hjo &
```

Voilà - Wilkommen im Team!