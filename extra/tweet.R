#' Make PaspberryPi post status to twitter
#' This twitterbot allows to actually stay in touch with the instrument.
#' Run this script at reboot, to be informed about IP adress
#' Opt-In crontab



# Init API
keyfile <- "./extra/twitter_credentials.R"
source(keyfile)

library(twitteR)
setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)



# Compose Tweet

# Tweet 🚀
msg <- paste(tweet, collapse = "\n")  
tweet(msg)