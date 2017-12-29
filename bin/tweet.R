#' Make PaspberryPi post status to twitter
#' This twitterbot allows to actually stay in touch with the instrument.
#' Opt-In crontab

## Dependencie
# library(twitteR)

## Input
#' msg
#' mediaPath

## Init API
keyfile <- paste0(wd, "/extra/twitter_credentials.R")
source(keyfile)
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)

## Modify Tweet
# #Hashtags
msg <- gsub("ARD", "#ARD", msg)
msg <- gsub("ZDF", "#ZDF", msg)
# or @Mentions
# msg[1] <- gsub("ARD", "ARD @tagesschau", msg[1])
# msg[1] <- gsub("ZDF HeuteJournal", "@heutejournal", msg[1])  # 1.
# msg[1] <- gsub("ZDF Heute", "@ZDFheute", msg[1])  # 2. Reihenfolge wichtig!

## Compose Tweet
# (msg <- paste(msg, collapse = "\n"))

## Tweet 🚀
if(!dev)
  tweet(msg, mediaPath = mediaPath)