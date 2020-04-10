# StandbildNews
This open-source project concerns the public german television. They host on-demand news, whereby the online available video contains blocked frames. Connected to a Raspberry Pi, herewith the blocekd fraction is measured, documented and posted online. For detailed informations please check out the [website](https://georoen.github.io/standbildNews/), [twitterbot](https://twitter.com/standbildNews) or [mastodon account](https://social.tchncs.de/@standbildNews), as this README.md focuses on the technical aspect.



## Dependencies
To run the software writen in [R](https://www.r-project.org/), you'll aditionally have to install some Linux libraries:   
`sudo apt install r-base ffmpeg libcurl4-openssl-dev libssl-dev libssh2-1-dev imagemagick libmagick++-dev git`

Next install the depending R packages:      
`install.packages(c("jpeg", "rvest", "ggplot2", "tibble", "lubridate", "stringr", "magick"))`.

Further, for communicating the results:
`install.packages("twitteR", "telegram.bot")`
and the [Mastodon package](https://github.com/ThomasChln/mastodon) not on CRAN:  
`devtools::install_github('ThomasChln/mastodon')  # install.packages("devtools")`



## Clone and Run this repository
Simply clone this repo with `git clone git@github.com:georoen/standbildNews.git`.  

Now give it a spin by e.g. processing the latest *ZDF 19Uhr* news:  
`Rscript --vanilla bin/MAIN.R h19 2`  
The syntax is `Rscript --vanilla` for sourcing the R script without saving the enviroment, `bin/heuteZensiert.R` calling the main, `h19` defining the news broadcast you want to stream and `2` for selecting the broadcast of two days ago.  
Along `h19` for *Heute 19Uhr*, also the other show of *ZDF* `hjo` for *Heute Journal*, as well as the two shows of *ARD*, `t20` for *Tagesschau* and `tth` *Tagesthemen* are implemented.  
The number `2` is an optional date parameter, selecting the show of two days ago.

Last but not least, you can add the following processes to [`crontab`](https://wiki.ubuntuusers.de/Cron/):  
```
0 20 * * * cd ~/standbildNews/ && nohup Rscript --vanilla bin/MAIN.R h19 &
0 21 * * * cd ~/standbildNews/ && nohup Rscript --vanilla bin/MAIN.R t20 &
0 22 * * *  cd ~/standbildNews/ && nohup Rscript --vanilla bin/MAIN.R tth &
0 23 * * *  cd ~/standbildNews/ && nohup Rscript --vanilla bin/MAIN.R hjo &
```
Whereby technically, you'll have to overwrite the social credentials stored in `extra/`, as well as need write accees to `Logfile.csv`. Please don't hesitate to contact us.



## Contribute
There are several ways how to contribute to this project:  
- Are the tweets correct? If you watch the above news on a regular basis and have a social account, please fave/interact with, if the blocked frames were detected correct. This helps to access the classifieres accuracy.  
- Add context to the blocked frames. It is not only interesting to know how much frames are missing, put also what is missing. Thus when you post a short reply about the blocked content, that would be very cool.
- Run a node. If you have a Raspberry Pi or any other server you can help processing the shows every day. Please do not hestitate to contact us, so we can share the credentials with you.

