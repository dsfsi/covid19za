# https://www.nicd.ac.za/latest-confirmed-cases-of-covid-19-in-south-africa-13-august-2021/

# on the gitlab runner, the working folder is /home/runner/work/covid19za/covid19za
# print(getwd())
if (interactive()) {  # for debug purposes
  setwd(file.path(dirname(rstudioapi::getActiveDocumentContext()$path),'/..'))
}


rss <- xml2::as_list(xml2::read_xml(httr::GET("https://www.nicd.ac.za/feed/"), 
                                    encoding="utf-8"))[[1]][[1]]
rss <- rss[names(rss)=="item"]
origtitle <- sapply(rss, getElement, "title") %>%
  gsub(".*\\((.*)\\)", "\\1", .)

pubDate <- sapply(rss, getElement, "pubDate")

names(rss) <- origtitle %>%   # only keep that in the brackets
  as.Date.character(format = "%d %B %Y") %>%
  as.character()

if (any(narss <- is.na(names(rss)))) {
  warning("Found NAs - ignoring these articles: '", paste0(origtitle[narss], collapse="', '"), "'")
  rss <- rss[!narss]
}
  
if (any(duplicated(names(rss)))) {
  stop("Duplicates found in the title of the daily cases - please check these")
}

rss <- lapply(rss, function(x) unlist(x$encoded))

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

tbls <- lapply(rss, XML::readHTMLTable, stringsAsFactors = FALSE, encoding="UTF-8")

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
    colnames(y) <- gsub("Ã|Â", "", make.names(y[1, ]))
    y <- y[-1, ]
    rownames(y) <- y[, 1]
    y <- y[, -1]
  })
}

cleantbls <- lapply(tbls, processDay)

Tests <- sapply(cleantbls, FUN = function(x) safe.as.numeric(x$Tests[, "Total.tested"]))
rownames(Tests) <- c("Private", "Public", "Total")

Hospital <- sapply(cleantbls, FUN=function(x) sapply(x$Hospital, safe.as.numeric), simplify = "array")
dimnames(Hospital)[[1]] <- c("Private", "Public", "Total")

Prov <- lapply(cleantbls, FUN=function(x) {  # x <- cleantbls[[1]]
  df <- x$Prov 
  keepCol <- regexpr("otal.cases", colnames(df), ignore.case = TRUE)>0
  keepRow <- c("Western Cape", "Eastern Cape", "Northern Cape", "Free State", "KwaZulu-Natal", "North West", "Gauteng", "Mpumalanga", "Limpopo", "Unknown", "Total")
  m <- match(keepRow, rownames(df))
  stopifnot(any(keepCol))
  df <- df[m, keepCol]  # remove everything else, new cases, percentages, etc.
  rownames(df) <- keepRow
  df["Unknown", is.na(df["Unknown", ])] <- 0   # change from NA to zero - for missing 
  # TODO: refine this hardcoded step
  df <- df[, 2:3]   # only keep column updated + new date
  df[] <- lapply(df, safe.as.numeric)
  
  # Fix column names
  dates <- gsub(".*(\\.[0-9]*\\.[^0-9]*\\.[0-9]*)","\\1", colnames(df)) %>%
    gsub("\\.\\.", "\\.", .) %>%
    gsub("\\.", " ", .) %>% 
    trimws() %>%
    as.Date.character(format = "%d %B %Y") %>%
    as.character()
  
  stopifnot(!any(is.na(dates)))
  colnames(df) <- dates
  
  df
})

ProvData <- t(do.call(cbind, Prov))

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
# replace cases data with new revised figures....
cases[m[!is.na(m)], names(Prov2Code)] <- ProvData[!is.na(m), Prov2Code] 
  
hasChanges <- apply(chgs, 1, FUN = function(x) sum(abs(x))>0)
cases$source[m[!is.na(m)]][hasChanges] <- paste0("gdb_revised_data_nicd-publishedOn-", PublishDate[!is.na(m)])[hasChanges]

if (any(is.na(m))) {
  # any new data?   Append this now....
  casesAdd <- as.data.frame(ProvData[which(is.na(m)), unname(Prov2Code), drop=FALSE])  # 3-11 == provinces
  colnames(casesAdd) <- names(Prov2Code)
  casesAdd$total <- rowSums(casesAdd)
  casesAdd$source <- "daily_nicd_scraper_gdb"
  casesAdd$YYYYMMDD <- gsub("-", "", rownames(casesAdd))
  casesAdd$date <- format(as.Date(rownames(casesAdd), format = "%Y-%m-%d"), "%d-%m-%Y")
  #re-order colnames
  casesAdd <- casesAdd[, colnames(cases)]
    
  message('There are some new extra data from sacoronavirus.co.za -- appending this to the data files')
  cases <- rbind(cases, 
                 casesAdd)
}

write.csv(cases, fnx, 
          row.names = FALSE, quote = FALSE, na = "")

# pragmatic - only commit when there were changes
if (length(git2r::status(px)$unstaged) > 0) {
  git2r::add(px, "data/covid19za_provincial_cumulative_timeline_confirmed.csv")
  git2r::commit(px, "Revised and new data from nicd.ac.za")
}



