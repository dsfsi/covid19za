# Author: Gerhard Bijker
# Daily DATCOV report from NICD
# 
URL <- "https://www.nicd.ac.za/diseases-a-z-index/disease-index-covid-19/surveillance-reports/daily-hospital-surveillance-datcov-report/"

library(magrittr)

# The daily provincial testing data was discontinued at some point in time.
# The national testing numbers are still available daily, but not the provincial details.
# This was replaced by a weekly PDF report at the URL above.
page <- xml2::read_html(URL, timeout=60)
links <- xml2::xml_attr(xml2::xml_find_all(page, "//a"), "href")

testrep <- regexec("https://www\\.nicd\\.ac\\.za/wp-content/.*\\.pdf", links) > 0
links <- links[testrep]

links <- rev(links)  # make then chronological
names(links) <- paste0(1000+seq.int(length(links)), "_", gsub("NICD-COVID-19-Daily-Sentinel-Hospital-Surveillance-report", "", basename(links)))
#names(links) <- gsub(".*uploads/([0-9]*).*Week-([0-9]*).*", "\\1-\\2", links)

# Manual fixes:
# luckily the "directory browsing is switched on.   Go to the relevant folder, and find the right file....
# https://www.nicd.ac.za/wp-content/uploads/2020/10/
links["1131_-PRIVATE-20201002.pdf"] <- ""   # file does not exist - ignore rather
links["1199_-National-20201228.pdf"] <- "https://www.nicd.ac.za/wp-content/uploads/2021/01/NICD-COVID-19-Daily-Sentinel-Hospital-Surveillance-report-National.31Dec2020.pdf"
#https://www.nicd.ac.za/wp-content/uploads/2021/01/DATCOV-National-report-20210101.pdf
#https://www.nicd.ac.za/wp-content/uploads/2020/12/NICD-COVID-19-Daily-Sentinel-Hospital-Surveillance-report-National-20201231.pdf

# remove all with the string "Pathogens-Report" in them
keep <- (regexec("Pathogens-Report", names(links)) == -1) & (links!="")
links <- links[keep]


if (parseLast10only <- !interactive()) {
  links <- tail(links, 10)
}


# now download all those PDF files....
tempfol <- "downloads/datcov"
if (do_download_missing <- TRUE) {
  if (!dir.exists(tempfol)) dir.create(tempfol)
  pool <- curl::new_pool()
  sapply(seq_along(links), function(i) {   # i <- 1
    fn <- paste0(tempfol, "/", names(links)[i])
    if (!file.exists(fn)) {
      curl::curl_fetch_multi(unname(links[i]), pool = pool,
                             data = file(fn, open = "wb"))
    } else {
      message(fn, " already exists.")
    }
  })
  # this starts the actual download
  curl::multi_run(pool = pool)
  # close all of the output connections....
  sapply(as.integer(rownames(showConnections())), FUN=function(x) close(getConnection(x)))
}

# Step 2:  process these PDF files, read the relevant sections, try to make sense out of this.
files <- setNames(paste0(tempfol, "/", names(links)),
                  names(links))
if (length(files) > 400) {
  files <- files[-1:-13]   # remove the first 9 files, they have a different format.   
  # real starting date:  1-Jun-2020, which is good enough
  # file 13 was missing - HTML instead of PDF, so skipping up to here.
}


# very speedy but basic extractor:  
basicTableExtractor <- function(fn) { # fn <- files[476]
  if (FALSE) {
    which(files=="downloads/datcov/1519_Datcov19_National_Export-20211105.pdf")
    which(files=="downloads/datcov/1357_National-datcov-report-08June.pdf")
    which(files=="downloads/datcov/1501_DATCOV-National-Report-20211018.pdf")
  }
  message(fn)
  x <- pdftools::pdf_text(fn)   # returns one big string per page
  
  
  if (length(x)==5) {
    x <- x[1:3]    # limit to the pages we are interested in, ignore the rest.
  }
  
  x2 <- strsplit(x, "\n")       # split into lines
  
  # Find the string "COVID-19 Surveillance" - use the date on this line.
  daterow <- which(regexpr("COVID-19.*Surveillance", x2[[1]]) > 0)    
  if (length(daterow)==0) {
    warning("File ", fn, " - unable to detect the date.  Ignoring this file.  ")
    table <- NULL
  } else {
    date <- substr(x2[[1]][daterow],1,50) %>%
      trimws() %>%
      as.Date.character(tryFormats = c("%A, %d %B %Y",
                                       "%A, %B %d, %Y",    # Tuesday, October 27, 2020
                                       "%d %B %Y"),
                        optional = TRUE) %>%    # otherwise, it will fail
      as.character()
    # try a different format from 18-Oct-2021 onwards - without the day of the week.
    if (is.na(date)) {
      stop("Error parsing date: ", substr(x2[[1]][daterow],1,50))
    }
    
    # skip: Hospital admissions of COVID-19 cases, by health sector, by epidemiological week
    # skip: Cumulative reported admissions by province, by epidemiological week
    
    # we might want to scrape the chart: "Deaths to date by age group and sex", but this will be hard.
    
    # We are most importantly interested in the tables on p2 - Summary of reported COVID-19 admissions by province, by sector
    # Use table on p3 as a check ???
    # Use table of p5 as a prov check ??? Private x Prov only?  
    # skip::  Hospital_group breakdown
    
    tablestart <- which(regexpr("Summary of reported COVID-19 admissions by province, by sector", x2[[2]]) > 0) + 1   
    table <- list(x2[[2]][tablestart:length(x2[[2]])])
    
    # older Format had charts below this table.   Wipe all of this
    stopTable <- which(regexpr("%ICU and %Ventilated", table[[1]]) > 0)
    if (length(stopTable)>0) {
      table[[1]] <- table[[1]][1:(stopTable-1)]
    }
    
    names(table) <- date
  }
  
  table
}

# cache this step -- much quicker
UseCache <- interactive() 
  
  
if (UseCache && file.exists(cachefn <- file.path(tempfol,"cache.rdata"))) {
  load(cachefn)
  # simulate missing data
  # data <- data[4:length(data)]
  if (length(missing <- setdiff(names(files), names(dataRaw)))>0) {
    # some new PDF files were downloaded and needs to be processed.
    dataRaw <- c(dataRaw, lapply(files[missing], basicTableExtractor))
    save(file=cachefn, dataRaw)
  }
} else {
  dataRaw <- lapply(files, basicTableExtractor)
  if (useCache) {
    save(file=cachefn, dataRaw)
  }
}

keep <- !sapply(dataRaw, is.null)
dataRaw <- dataRaw[keep]

dates <- sapply(dataRaw, names)
stopifnot(length(dates[is.na(dates)])==0)   # investigate different formats....
tables <- lapply(dataRaw, getElement, 1)
datesD <- as.Date(dates)
faultyYear <- as.integer(format(datesD, "%Y")) < 2020
datesD[faultyYear] <- datesD[faultyYear] + lubridate::years(2000)
dates <- as.character(datesD)
names(tables) <- dates

# re-order if something was added later....
tables <- tables[order(dates)]

errDups <- duplicated(names(tables))

if (sum(errDups)>0) {
  finderr <- function(probdate) {   # probdate <- names(tables)[errDups][1]
    probfile <- sapply(dataRaw, function(x) names(x)==probdate)
    print(names(probfile[probfile]))
  }
  
  # two errors: 
  # 1131_-PRIVATE-20201002.pdf must be 4-Oct-2020
  # 1199  must be                     31-Dec-2020
  lapply(names(tables)[errDups], finderr)
  stop("We found some errors:  different files names, but with similar content.  Fix please.")
  tables <- tables[!errDups]
}

if (FALSE) {
  head(sapply(tables, length), n=20)
  
  hist(sapply(tables2, length))
  base::table(sapply(tables2, length))
  
  probTable <- sapply(tables2, length) > 31
  names(tables2)[probTable]
}

furtherCleaning <- function(x) {
  emptyRow <- trimws(x)==""
  x <- x[!emptyRow]
  
  # sometimes we have a secondary table with 
  foundICU <- which(regexec("ICU", x) > 0)
  if(length(foundICU)>1 & foundICU[2]>20 ) {
    x <- x[1:(foundICU[2]-1)]
  }
  
  # 
  rubbishLines <- nchar(trimws(x))<10
  if (sum(rubbishLines)>0) {
    warning("About to ignore: ",trimws(x[rubbishLines]))
    x <- x[!rubbishLines]
  }
  x
}

tables2 <- lapply(tables, furtherCleaning)
# manual fix - Unknown prov - remove the two lines
tables2$`2021-02-19` <- tables2$`2021-02-19`[-27:-28] 
head(sapply(tables2, length), n=150)
# base::table(sapply(tables2, length))


ParseTable3 <- function(x) {    # x <- tables[500];   oldformat <- TRUE
  if (FALSE) {
    x <- tables2$`2020-10-27`   # second table with pub/priv totals - ignore th
  }
  numbers <- trimws(x)
  clean <-  numbers %>% 
    gsub("reporting[ ]*Admissions", "reporting\tAdmissions", .) %>%
    gsub("   ", "\t", .) %>%
    gsub(" ", "", .) %>%
    gsub("\t\t\t\t\t", "\t", .) %>%
    gsub("\t\t", "\t", .) %>%
    gsub("\t\t", "\t", .) %>%
    gsub("\t\t", "\t", .) %>%
    gsub("\t\t", "\t", .) %>%
    strsplit(., "\t")

  expectedNrCols <- median(sapply(clean, length))
  
  # detect the split-headers from 2020-10-27 onward
  if (length(clean)==30) {
    if (length(clean[[1]])==length(clean[[2]])) {
      clean[[1]] <- paste0(clean[[1]], clean[[2]])
      clean[[2]] <- NULL
    } else if (length(clean[[1]]) == length(clean[[2]])+1 ) {
      clean[[1]] <- paste0(clean[[1]], c("", clean[[2]]))    
      clean[[2]] <- NULL
    } else if (length(clean[[1]]) == length(clean[[2]])+2 ) {
      if (clean[[1]][3]=="AdmissionstoDate") {
        clean[[1]] <- paste0(clean[[1]], c("", "Reporting", "", clean[[2]][-1]))    
        clean[[2]] <- NULL
      } else {
        print(clean[1:2])
        stop("Unexpected header mess-up -2")
      }
    } else {
      print(clean[1:2])
      stop("Unexpected header mess-up")
    }
  }
  
  problemRows <- sapply(clean, length)!=expectedNrCols
  clean
  
  # as.data.frame(clean)
  
  # res <- as.data.frame(do.call(rbind, clean), stringsAsFactors = FALSE)
  
  # res[] <- lapply(res, FUN = as.numeric)
  
}

tables3 <- lapply(tables2, ParseTable3 )

p <- do.call(rbind, tables3[[1]][-1])
colnames(p) <- tables3[[1]][[1]]
as.data.frame(p)


# older back needs another different parser - thousand separator in the numbers, etc.
Table3 <- mapply(ParseTable3, data, as.list(names(data) <= "2020-33"), SIMPLIFY = FALSE)

# ARe all the provinces in the same order?  NO, they are NOT
checkCols <- sapply(T3x, colnames)
allOK <- apply(substr(checkCols[, 1],1,7)==substr(checkCols[],1,7), 2, all)
if (any(!allOK)) {
  stop("Provincial order problem")
}

allTestingData <- data.table::rbindlist(T3x, use.names = FALSE)  # we are checking the names above...

# cleanup dates
eoweek <- gsub("12\\-11 July", "12-18 Jul", allTestingData$week) %>%   # faulty label in 2020-30 - middle column
  gsub(".*(-|–) *","", .) %>%                
  gsub("April", "Apr", .) %>%
  gsub("August", "Aug", .) %>%
  gsub("July", "Jul", .) %>%
  gsub("June", "Jun", .) %>%
  gsub(" 20$", " 2020", .) %>% # change short year to long year
  gsub(" 21$", " 2021", .)
noyear <- nchar(eoweek)<10

eoweek[noyear] <- paste0(eoweek[noyear], " ", substr(allTestingData$weektag,1,4)[noyear])

allTestingData$eoweek <- as.Date.character(eoweek, format = "%d %B %Y")
if (any(probdates <- is.na(allTestingData$eoweek))) {
  print(allTestingData$week[probdates])
  stop("Could not convert strings into format Date type")
}

fixweektag <- function(wt) {  # convert to a numeric format, so that is could be sorted nicely
  # as.Date.character(wt, format="%Y-%U")   # not working - all week formatting is ignored on input..
  a <- strsplit(wt, "-")[[1]]
  as.integer(a[1]) + as.numeric(a[2])/100
}
allTestingData$weektagn <- sapply(allTestingData$weektag, fixweektag)

# ignore the first two reports, the week definitions are different from 2020.21 onwards.  
allTestingData <- allTestingData[weektagn>2020.20]

stopifnot(all(weekdays(allTestingData$eoweek, TRUE)=="Sat"))

# only keep the last available weektagn number, ignore the previous numbers
maxweektag <- allTestingData[, list(maxwtn=max(weektagn)), by=list(eoweek)]

allTestingData$latest <- maxweektag$maxwtn[ match(allTestingData$eoweek, maxweektag$eoweek) ] == allTestingData$weektagn 
allTestingData <- allTestingData[latest==TRUE][order(eoweek, var)]
allTestingData$source <- paste0(unname(links[allTestingData$weektag]),'#Table3')
allTestingData$eowYYYYMMDD <- format(allTestingData$eoweek, "%Y%m%d")

# re-order columns
# Put eo Week in YYYYMMDD format
provdatacols <- c("Eastern Cape","Free State", "Gauteng", "KwaZulu-Natal", "Limpopo", "Mpumalanga", "North West", "Northern Cape", "Western Cape", "Unknown", "Total")
allTestingData <- allTestingData[, c("weektag", "var", "week", "eowYYYYMMDD",
                                     ..provdatacols,
                                     "source")]

# save raw data into a raw file -- not cumulative
write.csv(allTestingData, "data/covid19za_provincial_timeline_testing.csv", 
          row.names = FALSE, quote = FALSE)

# Testing only, convert to cummulative number
rownames(allTestingData) <- paste0(allTestingData$var, '|', allTestingData$week)
cumTests <- allTestingData[allTestingData$var=="Tests", ..provdatacols]
cumTests[] <- lapply(cumTests, cumsum)
rownames(cumTests) <- allTestingData[allTestingData$var=="Tests", eowYYYYMMDD]

# tail(cumTests)   # Total cumm == 14.2 tests;   
# According to https://sacoronavirus.co.za/2021/08/21/update-on-covid-19-saturday-21-august-2021/,
# Total cumm tests should be 15.9 million.  
# ignore this....

provexUnknown <- provdatacols[-10]
PositivityRate <- data.table::setDF(
                  allTestingData[allTestingData$var=="Positive", ..provexUnknown] / 
                  allTestingData[allTestingData$var=="Tests", ..provexUnknown]
)
PositivityRate$YYYYMMDD <- allTestingData[allTestingData$var=="Tests", eowYYYYMMDD] 
write.csv(PositivityRate[, c(11,1:10)], "data/covid19za_provincial_timeline_testing_positivityrate.csv", 
          row.names = FALSE, quote = FALSE)

px <- git2r::repository()
git2r::config(px, user.name = "krokkie", user.email = "krokkie@users.noreply.github.com")

s <- git2r::status(px, staged = FALSE, untracked = FALSE)
if (length(s$unstaged)>0) {   # we have files that we can commit
  # if git2r::checkout()
  fns <- c("data/covid19za_provincial_timeline_testing_positivityrate.csv", 
           "data/covid19za_provincial_timeline_testing.csv")
  if (any(fns %in% s$unstaged)) {
    message("New data added - commiting now")
    git2r::add(px, "data/covid19za_provincial_timeline_testing_positivityrate.csv")  
    git2r::add(px, "data/covid19za_provincial_timeline_testing.csv")  
    git2r::commit(px, "Weekly testing data from NICD refreshed")  
  } else {
    message("No new data")
  }
}
