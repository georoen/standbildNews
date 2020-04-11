#' Make PaspberryPi post status to mastodon (social.tchncs.de)
#' This bot allows to actually stay in touch with the instrument.

#' Dependency:
#' devtools::install.github('ThomasChln/mastodon') 
#' library(mastodon)

#' Mastodon User: 
#' https://social.tchncs.de/@standbildNews

## Input
#' msg
#' mediaPath

## Init API
source("/extra/mastodon_credentials.R")

## Toot!
if(!dev){
  if (is.null(mediaPath)) {
    dump <- post_status(token, msg)
  } else {
    dump <- post_media(token, msg, file = mediaPath)
  }
}
