# curl 'https://mediathekviewweb.de/api/query' -H 'content-type: text/plain' --data '{"queries":[{"fields":["title","topic"],"query":"sturm der liebe"},{"fields":["channel"],"query":"ndr"}],"sortBy":"timestamp","sortOrder":"desc","future":false,"offset":0,"size":10}'



library(curl)
h <- new_handle()
handle_setopt(h, copypostfields = "moo=moomooo");
handle_setheaders(h,
                  "Content-Type" = "text/moo" #,
                  # "Cache-Control" = "no-cache",
                  # "User-Agent" = "A cow"
)


req <- curl_fetch_memory("http://httpbin.org/post", handle = h)
cat(rawToChar(req$content))



library(httr)
# curl 'https://mediathekviewweb.de/api/query' -H 'content-type: text/plain' 
--data '{"queries":[{"fields":["title","topic"],"query":"sturm der liebe"},{"fields":["channel"],"query":"ndr"}],
"sortBy":"timestamp","sortOrder":"desc","future":false,"offset":0,"size":10}'
res <- POST(url = "https://mediathekviewweb.de/api/query",
            add_headers("Content-type" = "text/plain"),
            # body = (list(queries = "{'channel':'ARD'}")),
            # query = list(channel = "ARD"),
            # query = list("!ard +tagesschau, 20:00 Uhr"),
            verbose())



library(rvest)
url <- "https://mediathekviewweb.de/feed?query=!ard%20%2Btagesschau%2C%2020%3A00%20Uhr"
rss <- read_html(url)
str(rss)
rss %>% 
  html_node()
