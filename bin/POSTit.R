#' Make PaspberryPi post on all channels (twitter, mastodon, telegran)
#' E.g. to communicate service postings.

#' Input Arguments
#' msg = "Hello World! We love you <3"  # Character string.
#' mediaPath = NULL  # Optional character path


#### Argumente ####
args <- commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
  ### Keine Argumente. Default ist h19 von heute.
  warning("Keine Argumente. Verwende default", call.=FALSE)
  msg <- "Hello World! We love you <3"
  mediaPath <- NULL
} else if (length(args)==1) {
  msg <- args[1]
  mediaPath <- NULL
} else if (length(args)==2) {
  msg <- args[1]
  mediaPath <- args[2]
}
  
opt_social <- FALSE

#### Twitter ####
if (require(twitteR) && 
    file.exists("extra/twitter_credentials.R")) {
  source("bin/tweet.R")
}

#### Mastodon ####
if (require(mastodon) && 
    file.exists("extra/mastodon_credentials.R")) {
  source("bin/toot.R")
}

#### Telegram Bot Message ####
if (require(telegram.bot) && 
    file.exists("extra/standbildNews_bot.key") && 
    file.exists("extra/standbildNews_group.id")) {
  source("bin/telegram_bot.R")
}
