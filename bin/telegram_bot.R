library(telegram.bot)

token <- readLines("extra/standbildNews_bot.key")
group <- readLines("extra/standbildNews_group.id")

bot <- Bot(token = token)

if (is.null(mediaPath)) {
  bot$sendMessage(chat_id = group,
                  text = msg)
} else {
  bot$sendPhoto(chat_id = group,
                photo = mediaPath,
                caption = msg)
}