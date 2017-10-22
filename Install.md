# Installation
Um das Programm zu installieren,  müssen folgende Dependencies erfüllt sein:  
  **Linux** `sudo apt install ffmpeg imagemagick libmagick++-dev libtesseract-dev libleptonica-dev tesseract-ocr-eng tesseract-ocr-deu`.  
**R:** `jpeg`, `ggplot2`, `tibble`, `lubridate`, `stringr`, `imagick`, `tesseract`.

Hier werden mit `CRONTAB` täglich die Nachrichten-Sendungen, 50 Minuten nach regulärer TV-Ausstrahlung, via RSS abgerufen.
```
# 50 19 * * * cd ~/heuteZensiert/ && nohup Rscript --vanilla bin/heuteZensiert.R h19 &
# 50 20 * * * cd ~/heuteZensiert/ && nohup Rscript --vanilla bin/heuteZensiert.R t20 &
# 50 23 * * *  cd ~/heuteZensiert/ && nohup Rscript --vanilla bin/heuteZensiert.R hjo &
```
