# Author: gerh@rd.co.za
# Script that scrapes the sacoronavirus.co.za website
# https://sacoronavirus.co.za/covid-19-daily-cases/

print(getwd())
stop("debug")

rss <- xml2::as_list(xml2::read_xml(httr::GET("https://sacoronavirus.co.za/feed/")))[[1]][[1]]
junk <- sapply(rss, function(x) (is.null(x$category)) || (unlist(x$category)!="Daily Cases"))
rss <- rss[!junk]
origtitle <- sapply(rss, getElement, "title") %>%
  gsub(".*\\((.*)\\)", "\\1", .) %>% 
  trimws()

pubDate <- sapply(rss, getElement, "pubDate")
# fix mistakes here
origtitle <- gsub("Tuesday 09 August 2021", "Tuesday 10 August 2021", origtitle)

names(rss) <- origtitle %>%   # only keep that in the brackets
  as.Date.character(format = "%A %d %B %Y") %>%
  as.character()

if (any(duplicated(names(rss)))) {
  stop("Duplicates found in the title of the daily cases - please check these")
}

rss <- lapply(rss, function(x) unlist(x$encoded))

