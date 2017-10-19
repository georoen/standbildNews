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

## Compose Tweet
msg <- paste(msg, collapse = "\n")  
## Tweet 🚀
tweet(msg, mediaPath = mediaPath)