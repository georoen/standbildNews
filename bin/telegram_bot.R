#' Make PaspberryPi post status to telegram
#' This twitterbot allows to actually stay in touch with the instrument.

## Dependencie
# library(telegram.bot)

## Input
#' msg
#' mediaPath

token <- readLines("extra/standbildNews_bot.key")
group <- readLines("extra/standbildNews_group.id")

## Init API
bot <- Bot(token = token)

## Send!
if(opt_social){
  if (is.null(mediaPath)) {
    bot$sendMessage(chat_id = group,
                    text = msg)
  } else {
    bot$sendPhoto(chat_id = group,
                  photo = mediaPath,
                  caption = msg)
  }
}
