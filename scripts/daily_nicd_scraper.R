# Author: gerh@rd.co.za
# Script that scrapes the nicd.ac.za website
# https://www.nicd.ac.za/latest-confirmed-cases-of-covid-19-in-south-africa-13-august-2021/
library(magrittr)

# on the gitlab runner, the working folder is /home/runner/work/covid19za/covid19za
# print(getwd())
if (interactive()) {  # for debug purposes
  setwd(file.path(dirname(rstudioapi::getActiveDocumentContext()$path),'/..'))
}

readFromRSSfeed <- function() {
  rss <- xml2::as_list(xml2::read_xml(httr::GET("https://www.nicd.ac.za/feed/"), 
                                      encoding="utf-8"))[[1]][[1]]
  rss <- rss[names(rss)=="item"]
  origtitle <- sapply(rss, getElement, "title") %>%
    gsub(".*\\((.*)\\)", "\\1", .)
  
  #pubDate <- sapply(rss, FUN = function(x) x$pubDate[[1]])

  names(rss) <- origtitle %>%   # only keep that in the brackets
    as.Date.character(format = "%d %B %Y") %>%
    as.character()
  
  if (any(narss <- is.na(names(rss)))) {
    message("Found NAs - ignoring these articles: '", paste0(origtitle[narss], collapse="', '"), "'")
    rss <- rss[!narss]
  }
  
  if (any(duplicated(names(rss)))) {
    stop("Duplicates found in the title of the daily cases - please check these")
  }
  
  detailpageurls <- sapply(rss, getElement, "link")
  
  rss <- lapply(rss, function(x) unlist(x$encoded))

  data.frame(date=names(rss), 
             #pubdate=unname(pubDate),
             content=unlist(unname(rss)),
             source=unlist(detailpageurls), stringsAsFactors = FALSE)  
}

readHistory <- function(maxPages = 100) {
  entry <- xml2::read_html(entryurl <- 'https://www.nicd.ac.za/media/alerts/')
  
  pager <- xml2::xml_find_all(entry, "//nav[contains(@class, 'elementor-pagination')]")
  urls <- xml2::xml_find_all(pager, ".//a") %>%
    xml2::xml_attr("href") %>%
    unique()    # next and specific page the same destination
  
  if (!is.null(maxPages)) {
     articlesperpage <- 8  # actuall 10, but on average about 10 covid related ones.
     maxurls <- ceiling(maxPages / articlesperpage) + 3  # some margin for non-COVID articles
     if (maxurls > length(urls)) urls <- urls[1:maxurls]  # shorten this - as an optimization 
  }
  
  # TODO: optimizations - change from sequential read to async read
  entries <- lapply(c(entryurl, urls), xml2::read_html) 
  
  processPage <- function(page) {
    articlesOnPage <- xml2::xml_find_all(page, "//article[contains(@class, 'category-alerts')]")
    getLink <- function(art) {   # art <- articlesOnPage[1]
      xml2::xml_find_first(art, ".//a") %>%
        xml2::xml_attr("href")
    }
    sapply(articlesOnPage, getLink)
  }
  
  allLinks <- unlist(sapply(entries, processPage))
  
  readPageContent <- function(url) {  # url <- allLinks[100]
    tryCatch({
      p <- xml2::read_html(url)
      # content of the news item
      
      content <- as.character(xml2::xml_find_all(p, "//div[contains(@class, 'elementor-widget-theme-post-content')]"))
      # the publication date
      # xml2::xml_find_all(p, "//div[contains(@class, 'elementor-widget-post-info')]")
      date <- trimws(xml2::xml_text(xml2::xml_find_all(p, "//span[contains(@class, 'elementor-post-info__item--type-date')]"))) %>%
        as.Date.character(format="%d %B , %Y")
      success <- TRUE
    }, error = function(x) {
      warning(x)
      success <- FALSE
    })
    list(date=date, 
         content=content,
         source=url,
         OK=success)
  }

  # filter these, as not all of these are COVID related.   
  covid <- regexpr("covid", allLinks, ignore.case = TRUE) > 0

  allLinks <- allLinks[covid]
  # 
  if (!is.null(maxPages)) {
    allLinks <- head(allLinks, maxPages)
  }
  #TODO: read async
  allData <- lapply(allLinks, readPageContent)

  df <- data.table::rbindlist(allData)  
}

if (runRSSonly <- TRUE) {
  rssdf <- readFromRSSfeed()
} else {
  rssdf <- readHistory()
}

safe.as.numeric <- function(x) {
  stopifnot(is.vector(x))
  # x <- Tests$`2021-08-07`$Total.tested
  x <- gsub("\u00A0|\t| |Ã|Â|,", "", x)  # remove space and thousand separators
  strsplit(x[[1]], split = FALSE)
  n <- as.numeric(x)
  if (any(faultyfield <- is.na(n))) {
    stop("String to numeric problem: ", x[faultyfield])
  } 
  n
}

tbls <- lapply(setNames(rssdf$content, rssdf$date), XML::readHTMLTable, stringsAsFactors = FALSE, encoding="UTF-8")

hasValue <- function(df, val) {  # df <- x[[1]];   val <- "Private"
  any(apply(df, 2, function(x) any(!is.na(x) & x==val)))
}

processDay <- function(x) {
  # x <- tbls[[1]]
  HasTest <- which(sapply(x, hasValue, "Total tested"))
  HasProv <- which(sapply(x, hasValue, "Gauteng"))
  HasHosp <- which(sapply(x, hasValue, "Facilities Reporting"))
  stopifnot(length(HasTest)==1L)
  stopifnot(length(HasProv)==1L)
  stopifnot(length(HasHosp)==1L)
  
  x <- x[c(HasTest, HasProv, HasHosp)]
  names(x) <- c("Tests", "Prov", "Hospital")
  
  # col and row names
  lapply(x, function(y) { # y <- x[[1]]
    # remove an empty line if present
    if (paste0(y[1, ] %>% inset(is.na(.), value=""), collapse="")=="") {
      y <- y[-1, ]
    }    
    colnames(y) <- gsub("Ã|Â", "", make.names(y[1, ]))
    y <- y[-1, ]
    # sometimes a double empty row at the start....
    rownames(y) <- y[, 1]
    y <- y[, -1]
    # remove empty rows
    keepRow <- apply(y, 1, FUN = function(x) !all(is.na(x) | trimws(x)==""))
    keepCol <- apply(y, 2, FUN = function(x) !all(is.na(x) | trimws(x)==""))
    y[keepRow, keepCol, drop=FALSE]
  })
}

# sometimes we have news items that has a COVID in the title, but is not the regular updates....
OK <- sapply(tbls, length)>=3
if (!all(OK)) {
  message("Ignoring these URLs: ", paste0(rssdf[!OK, "source"], collapse=","))
  tbls <- tbls[OK]
}

cleantbls <- lapply(tbls, processDay)

# sapply(cleantbls, FUN=function(x) colnames(x$Tests))
# tx <- sapply(cleantbls, FUN = function(x) "Total.tested" %in% colnames(x$Tests))
# sapply(cleantbls, FUN = function(x) length(x$Tests[, "Total.tested"]))
Tests <- sapply(cleantbls, FUN = function(x) safe.as.numeric(x$Tests[, "Total.tested"]))
rownames(Tests) <- c("Private", "Public", "Total")

Hospital <- sapply(cleantbls, FUN=function(x) sapply(x$Hospital, safe.as.numeric), simplify = "array")
dimnames(Hospital)[[1]] <- c("Private", "Public", "Total")

if (DEBUG <- FALSE) {
  p1 <- lapply(cleantbls, getElement, "Prov")
  cn <- sapply(p1, colnames)
  rn <- sapply(p1, rownames)
}
Prov <- lapply(cleantbls, FUN=function(x) {  # x <- cleantbls[[1]]
  df <- x$Prov 
  keepCol <- regexpr("otal.cases", colnames(df), ignore.case = TRUE)>0
  keepRow <- c("Western Cape", "Eastern Cape", "Northern Cape", "Free State", "KwaZulu-Natal", "North West", "Gauteng", "Mpumalanga", "Limpopo", "Unknown", "Total")
  m <- match(keepRow, rownames(df))
  stopifnot(any(keepCol))
  df <- df[m, keepCol, drop=FALSE]  # remove everything else, new cases, percentages, etc.
  rownames(df) <- keepRow
  df["Unknown", is.na(df["Unknown", ])] <- 0   # change from NA to zero - for missing 
  if (ncol(df)>=3) {  
    #TODO: refine this hardcoded step TOTAL prev, UPDATED prev, TOTAL new  [sometimes a faulty extra column] 
    df <- df[, 2:3]   # only keep column updated + new date
  } 
  df[] <- lapply(df, safe.as.numeric)
  
  # Fix column names
  dates <- gsub(".*(\\.[0-9]*\\.[^0-9]*\\.[0-9]*)","\\1", colnames(df)) %>%
    gsub("\\.\\.", "\\.", .) %>%
    gsub("\\.", " ", .) %>% 
    trimws() %>%
    gsub("September", "Sep", .) %>%     # Most problably an Afrikaans-speaking user....?
    gsub("Sept", "Sep", .) %>%
    as.Date.character(format = "%d %B %Y") %>%
    as.character()
  
  if (any(is.na(dates))) {
    print(colnames(df)[is.na(dates)])
    stop("Error converting strings to dates")
  }
  colnames(df) <- dates
  
  df
})

# check for column naming errors relative to the published date...
cn <- sapply(Prov, colnames)
singleCol <- sapply(cn, length)==1

# fix single-Column named problems
problemColnameIdx <- setNames(names(cn)[singleCol]!=unname(unlist(cn[singleCol])), names(cn)[singleCol])
problemColname <- names(problemColnameIdx[problemColnameIdx])
lapply(problemColname, function(n) {  # n <- '2021-06-18'
  warning("Adjusting data for ", n, " - different publishing date vs. column label")
  colnames(Prov[[n]]) <<- n 
})

# fix multi-column named problems
checkMultiCol <- lapply(cn[!singleCol], max)
problemColnameIdx <- setNames(unname(checkMultiCol)!=names(checkMultiCol), names(cn)[!singleCol])
problemColname <- names(problemColnameIdx[problemColnameIdx])
lapply(problemColname, function(n) {  # n <- '2021-08-12'
  delta <- as.Date(n) - as.Date(max(colnames(Prov[[n]])))
  warning("Adjusting data for ", n, " - different publishing date vs. column label - ", delta, " day difference")
  colnames(Prov[[n]]) <<- as.character(as.Date(colnames(Prov[[n]])) + delta) 
})



# Now combine all of this
ProvData <- t(do.call(cbind, Prov))
singleDate <- nchar(rownames(ProvData))==10
rownames(ProvData)[singleDate] <- paste0(rownames(ProvData)[singleDate],".",
                                         rownames(ProvData)[singleDate]) 

xx <- strsplit(rownames(ProvData), split = "\\.")
# Assumption:  data reported for a couple of days back, is more accurate than what it was reported on that day.
d1=as.Date(sapply(xx, getElement, 1))
d2=as.Date(sapply(xx, getElement, 2))
dx=as.integer(d1-d2)
alldates <- sort(unique(d2))
mx=aggregate(dx, by=list(d2), FUN=max)
keep <- match(paste0(mx$Group.1+mx$x, ".", mx$Group.1), rownames(ProvData))
ProvData <- ProvData[keep, ]
PublishDate <- substr(rownames(ProvData),1,10)
rownames(ProvData) <- substr(rownames(ProvData),12,22)

# update the packages....
# install.packages("git2r")
px <- git2r::repository()
git2r::config(px, user.name = "krokkie", user.email = "krokkie@users.noreply.github.com")

cases <- read.csv(fnx <- paste0('data/covid19za_provincial_cumulative_timeline_confirmed.csv'), 
                  stringsAsFactors = FALSE)
# find these dates in the data file....
m <- match(format(as.Date(rownames(ProvData), format = "%Y-%m-%d"), "%d-%m-%Y"), cases$date)
Prov2Code <- c(WC="Western Cape", EC="Eastern Cape", NC="Northern Cape", FS="Free State", 
               KZN="KwaZulu-Natal", NW="North West", GP='Gauteng', MP="Mpumalanga", LP="Limpopo", UNKNOWN="Unknown")
oldcases <- cases[m[!is.na(m)], names(Prov2Code)]
chgs <- ProvData[!is.na(m), Prov2Code] - oldcases
rownames(chgs) <- rownames(ProvData)[!is.na(m)]

# replace cases data with new revised figures.... -- only if this changed significantly.
hasChanges <- apply(chgs, 1, FUN = function(x) sum(abs(x))>2)
sourcex <- setNames(rssdf$source, rssdf$date)
if (any(hasChanges)) {
  cases[m[!is.na(m)][hasChanges], names(Prov2Code)] <- ProvData[!is.na(m), Prov2Code][hasChanges, ] 
  cases$source[m[!is.na(m)]][hasChanges] <- unlist(unname(sourcex[PublishDate[!is.na(m)][hasChanges] ]))
}

if (any(is.na(m))) {
  # any new data?   Append this now....
  casesAdd <- as.data.frame(ProvData[which(is.na(m)), unname(Prov2Code), drop=FALSE])  # 3-11 == provinces
  colnames(casesAdd) <- names(Prov2Code)
  casesAdd$total <- rowSums(casesAdd)

  casesAdd$source <- unlist(unname(sourcex[rownames(casesAdd)]))
  casesAdd$YYYYMMDD <- gsub("-", "", rownames(casesAdd))
  casesAdd$date <- format(as.Date(rownames(casesAdd), format = "%Y-%m-%d"), "%d-%m-%Y")
  #re-order colnames
  casesAdd <- casesAdd[, colnames(cases)]
    
  message('There are some new extra data from nicd.ac.za -- appending this to the data files')
  cases <- rbind(cases, 
                 casesAdd)
}

write.csv(cases[order(cases$YYYYMMDD), ], fnx, 
          row.names = FALSE, quote = FALSE, na = "")

# pragmatic - only commit when there were changes
targetfn <- "data/covid19za_provincial_cumulative_timeline_confirmed.csv"
if (length(unstaged <- git2r::status(px)$unstaged) > 0 & 
    targetfn %in% unstaged) {
  git2r::add(px, targetfn)
  git2r::commit(px, "Revised and new data from nicd.ac.za")
}

if (UpdateTestingTotals <- FALSE) {
  # Under construction -- needs some attention.
  tests <- read.csv(fnx <- paste0('data/covid19za_timeline_testing.csv'), 
                    stringsAsFactors = FALSE)
  m <- match(format(as.Date(colnames(Tests), format = "%Y-%m-%d"), "%d-%m-%Y"), tests$date)
  
  if (any(is.na(m))) {
    tAdd <- as.data.frame(t(Tests[c("Total", "Private", "Public"), which(is.na(m)), drop=FALSE]))  # 3-11 == provinces
    colnames(tAdd) <- colnames(tests)[3:5]
    
    tAdd$source <- unlist(unname(detailpageurls[rownames(tAdd)]))
    tAdd$YYYYMMDD <- gsub("-", "", rownames(tAdd))
    tAdd$date <- format(as.Date(rownames(tAdd), format = "%Y-%m-%d"), "%d-%m-%Y")
    
    # Hospital variable
    # dim(Hospital)   # priv/pub/tot x facilitiesReporting, Admissionsto.Date, Died.to.Date, Currently.Admitted
    # tests$hospitalisation ??  What variable goes in here? 
    hospadm <- Hospital["Total", "Admissionsto.Date", ]
    m2 <- match(rownames(tAdd), names(hospadm))
    tAdd$hospitalisation <- hospadm[m2]  # variable not populated...

    # national figures - deaths etc. 
    deaths <- read.csv('data/covid19za_provincial_cumulative_timeline_deaths.csv', stringsAsFactors = FALSE)
    m2 <- match(tAdd$YYYYMMDD, deaths$YYYYMMDD)
    tAdd$deaths <- deaths$total[m2]
    
    recov <- read.csv('data/covid19za_provincial_cumulative_timeline_recoveries.csv', stringsAsFactors = FALSE)
    m2 <- match(tAdd$YYYYMMDD, recov$YYYYMMDD)
    tAdd$recovered <- recov$total[m2]
    
    t2 <- data.table::rbindlist(list(tests, tAdd), fill=TRUE)[order(YYYYMMDD)]
    tail(t2, 20)
  }
}


