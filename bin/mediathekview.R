library(rvest)

newField <- function(field, query) {
  paste0('{"fields":["', paste0(field, collapse = '","'), '","query":"', query, '"}')
}

newField(c("title", "topic"), "Tagesschau")
newField("channel", "ARD")

header <- "curl 'https://mediathekviewweb.de/api/query' -H 'content-type: text/plain'"
data <- paste0("--data '{",
               # Filters
               paste0('"queries":[',
                      newField(c("title", "topic"), "Tagesschau"),
                      ",",
                      newField("channel", "ARD"),
                      "]"),
               ",",
               # Sorting
               paste0('"sortBy":"timestamp","sortOrder":"desc","future":false,"offset":0,"size":10'),
               "}'")

(cmd <- paste(header, data))
system(cmd)
html(cmd)
paste('curl 'https://mediathekviewweb.de/api/query' -H 'content-type: text/plain' 
      --data '{"queries":[{"fields":["title","topic"],"query":"sturm der liebe"},{"fields":["channel"],"query":"ndr"}],
               "sortBy":"timestamp","sortOrder":"desc","future":false,"offset":0,"size":10}'')