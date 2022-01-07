# Author: Gerhard Bijker
# Weekly testing data from NICD
# 
URL <- "https://www.nicd.ac.za/diseases-a-z-index/disease-index-covid-19/surveillance-reports/weekly-testing-summary/"

library(magrittr)

# The daily provincial testing data was discontinued at some point in time.
# The national testing numbers are still available daily, but not the provincial details.
# This was replaced by a weekly PDF report at the URL above.
page <- xml2::read_html(URL)
links <- xml2::xml_attr(xml2::xml_find_all(page, "//a"), "href")

testrep <- regexec("https://www\\.nicd\\.ac\\.za/wp-content/.*\\.pdf", links) > 0
links <- links[testrep]
names(links) <- gsub(".*uploads/([0-9]*).*Week-([0-9]*).*", "\\1-\\2", links)
# week 53 2020 is wrong, fix manually
names(links)[links=="https://www.nicd.ac.za/wp-content/uploads/2021/01/COVID-19-Testing-Summary-Week-53.pdf"] <- "2020-53"
names(links)[links=="https://www.nicd.ac.za/wp-content/uploads/2022/01/COVID-19-Testing-Report_Week-52.pdf"] <-  "2021-52"

# now download all those PDF files....
tempfoltesting <- "downloads/nicd-testing"
if (do_download_missing <- TRUE) {
  if (!dir.exists(tempfoltesting)) dir.create(tempfoltesting)
  pool <- curl::new_pool()
  sapply(seq_along(links), function(i) {   # i <- 1
    fn <- paste0(tempfoltesting, "/", names(links)[i], ".pdf")
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
files <- setNames(paste0(tempfoltesting, "/", names(links), ".pdf"),
                  names(links))

# very speedy but basic extractor:  
basicTableExtractor <- function(fn) { # fn <- "downloads/nicd-testing/2020-22.pdf"
  message(fn)
  x <- pdftools::pdf_text(fn)   # returns one big string per page
  x2 <- strsplit(x, "\n")       # split into lines
  
  pagelen <- sapply(x2, length)
  page <- cumsum(unlist(sapply(pagelen, seq.int))==1)   # 
  
  x3 <- unlist(x2)
  Tables <- regexpr("^Table", x3) > 0
  tableStartOnPage <- page[Tables]
  tableEndLine <- cumsum(pagelen)[page[Tables]+1]  # end of the next page
  tableEndLine[is.na(tableEndLine)] <- max(cumsum(pagelen))
  startNextTable <- c(which(Tables)[-1], 9999) - 1
  tableStart <- which(Tables)
  tableEnd <- pmin(startNextTable, tableEndLine)
  tableName <- substr(x3[Tables], 1, 15)
  
  tbls <- setNames(mapply(function(start, end) x3[start:end], tableStart, tableEnd), 
                   nm=tableName)
}

# cache this step -- much quicker
if (file.exists(cachefn <- file.path(tempfoltesting,"cache.rdata"))) {
  load(cachefn)
  # simulate missing data
  # data <- data[4:length(data)]
  if (length(missing <- setdiff(names(files), names(data)))>0) {
    # some new PDF files were downloaded and needs to be processed.
    data <- c(data, lapply(files[missing], basicTableExtractor))
    save(file=cachefn, data)
  }
} else {
  data <- lapply(files, basicTableExtractor)
  save(file=cachefn, data)
}

ParseTable3 <- function(x, oldformat) {    # x <- data[[62]];   oldformat <- TRUE
  if (FALSE) {
    x <- data$`2021-52`
    oldformat <- FALSE
    
  }
  if (length(x) < 5) {
    # new table format introduced 2021-36 onwards
    message(substr(x$`Table 2. Weekly`[1],80,120))
    t3 <- x$`Table 2. Weekly`[1:30]
  } else {
    message(substr(x$`Table 3. Weekly`[1],80,120))
    t3 <- x$`Table 3. Weekly`[1:30] 
  }
  
  
  provspace <- 25
  prov <- trimws(substr(t3,1,provspace))
  firstline <- which(prov=="Western Cape")
  if (length(firstline)==0) {
    # try 
    provspace <- 15
    prov <- trimws(substr(t3,1,provspace))
    firstline <- which(prov=="Western Cape")
  }  
  
  lastline <- which(prov=="Total")
  if (length(lastline)==0) {
    # try 
    provspace <- 20
    prov <- trimws(substr(t3,1,provspace))
    lastline <- which(prov=="Total")
  }  

  provs <- prov[firstline:lastline]
  t3 <- t3[1:lastline]
  numbers <- trimws(substr(t3[firstline:lastline],provspace+1,999))
  if (oldformat) {
    clean <-  numbers %>% 
      gsub("  ", "\t", .) %>%
      gsub(" ", "", .) %>%
      gsub("\t\t\t\t\t", "\t", .) %>%
      gsub("\t\t", "\t", .) %>%
      gsub("\t\t", "\t", .) %>%
      gsub("\t\t", "\t", .) %>%
      gsub("\t\t", "\t", .) %>%
      gsub("([0-9])\\(", "\\1\t(", .) %>%
      gsub("\\([0-9\\.]*\\)", "", .) %>%    #remove the figures in brackets entirely
      gsub("\\(0\\.6", "", .) %>%           # Northern Cape error somewhere in the early reports
      gsub("\t\t", "\t", .) %>%
      gsub("\t\t", "\t", .) %>%
      strsplit(., "\t")
  } else {
    clean <-  numbers %>% 
      gsub("    ", " ", .) %>%
      gsub("    ", " ", .) %>%
      gsub("   ", " ", .) %>%
      gsub("  ", " ", .) %>%
      gsub("  ", " ", .) %>%
      gsub("  ", " ", .) %>%
      gsub("  ", " ", .) %>%
      gsub(",", "", .) %>%    # remove "," thousand separators
      strsplit(., " ")
  }
  
  # fix missing gaps between pop and cases
  nrchars <- sapply(clean, function(x) nchar(x[1]))
  nrchars[is.na(nrchars)] <- 0
  problem <- (nrchars>8)
  if (any(problem)) {
    popdigits <- as.integer((nrchars[problem] + 3) / 2)  # 7 or 8
    errItem <- sapply(clean[problem], getElement, 1)
    clean[problem] <- mapply(function(v1, v2, old) c(v1,v2, old[-1]), 
                             as.list(substr(errItem, 1, popdigits)),
                             as.list(substr(errItem, popdigits+1, 99)),
                             clean[problem], SIMPLIFY = FALSE)
  }

  names(clean) <- provs

  # remove empty lines
  emptyline <- sapply(clean, length)==0 | 
               paste0(clean)==""
  clean <- clean[!emptyline]
  
  # specific fixes when something goes wrong...  
  colsdetected <- sapply(clean, length)
  if (!oldformat) {
    if(length(provs)==12 &
       provs[11]=="" &
       colsdetected[11]==1 & 
       colsdetected[12]==10) {
      t3
      clean[[12]] <- c(clean[[12]][1:2], clean[[11]], NA, clean[[12]][3:10])
      clean[[11]] <- NULL
      colsdetected <- sapply(clean, length)
    }
    if(length(provs)==12 &
       provs[6]=="" &
       colsdetected[5]==1 & 
       colsdetected[6]==11) {
      clean[[5]] <- c(clean[[6]][1], clean[[5]], clean[[6]][2:11])
      clean[[6]] <- NULL
      colsdetected <- sapply(clean, length)
    }
    if(length(provs)==12 &   # Total column - last two cols missing
       provs[11]=="" &
       colsdetected[11]==2 & 
       colsdetected[12]==8) {
      clean[[12]] <- c(clean[[12]][1:5], clean[[11]][1], NA, clean[[12]][6], clean[[11]][2], NA, clean[[12]][7:8])
      clean[[11]] <- NULL
      colsdetected <- sapply(clean, length)
    }
    if (colsdetected[["Unknown"]]==9) {
      clean$Unknown <- c(0, clean$Unknown, rep(NA, colsdetected[[1]]-10))
    }
    if (colsdetected[["Unknown"]]==10) {
      clean$Unknown <- c(0, clean$Unknown[1:9], NA, clean$Unknown[10])
    }
    
    colsdetected <- sapply(clean, length)
    if (!all(colsdetected[[1]]==colsdetected)) {
      print(colsdetected)
      stop("Found an odd column")
    }
    
    if (! colsdetected[1] %in% c(11,12)) {
      print(colsdetected)
      stop("Expected 11 or 12 columns - but found the above")
    }

    res <- as.data.frame(do.call(rbind, clean), stringsAsFactors = FALSE)
    res <- res[, c(2,3, 5,6, 8,9)]  # skip the population numbers, and the final rates
    
    # skip empty line
    if (t3[2]=="" | trimws(t3[2])=="Change in")  t3 <- t3[c(1, 3:length(t3))]
    if (t3[2]=="" | trimws(t3[2])=="Change in")  t3 <- t3[c(1, 3:length(t3))]
    
    dates <- strsplit(t3[2], "  ") %>%
      extract2(1) %>%
      extract(. != "") %>%
      trimws()
    rmp <- dates=="percentage"
    if (any(rmp)) {
      dates <- dates[!rmp]
    }
    
    stopifnot(length(dates)>0)
    colnames(res) <- c(t(outer(X=dates, Y=c("Tests", "Positive"), FUN = function(x,y) paste0(y,"|",x))))
    res[] <- lapply(res, FUN = as.numeric)

  } else {
    # old format fixes
    
    colsdetected <- sapply(clean, length)
    if (colsdetected["Unknown"]==6 & 
        colsdetected["Limpopo"]==8) {
      clean$Unknown <- c(NA, clean$Unknown, NA)   # pop and poprate removed.
      colsdetected <- sapply(clean, length)
    }
    if (!all(colsdetected[[1]]==colsdetected)) {
      print(colsdetected)
      stop("Found an odd column")
    }
    
    #Unknown fix
    # as.data.frame(clean)
    res <- as.data.frame(do.call(rbind, clean), stringsAsFactors = FALSE)
    if (colsdetected[[1]]==8) {
      res <- res[, 2:7]  # skip the population numbers, and the final rates
    }
    
    dates <- strsplit(t3[2], "  ") %>%
      extract2(1) %>%
      extract(. != "") %>%
      trimws()
    colnames(res) <- c(t(outer(X=dates, Y=c("Tests", "Positive"), FUN = function(x,y) paste0(y,"|",x))))
    res[] <- lapply(res, FUN = as.numeric)
  }
  
  res
}

# older back needs another different parser - thousand separator in the numbers, etc.
Table3 <- mapply(ParseTable3, data, as.list(names(data) <= "2020-33"), SIMPLIFY = FALSE)

T3x <- mapply(function(df, weektag) {  # df <- Table3[[1]]
  res <- as.data.frame(t(df))
  # re-order the provinces to alphabetical order.  
  res <- res[, order(colnames(res))]
  cols <- strsplit(rownames(res), "\\|")
  res$weektag <- weektag
  res$var <- sapply(cols, getElement, 1)
  res$week <- sapply(cols, getElement, 2)
  res
}, Table3, names(Table3), SIMPLIFY = FALSE)

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
} else {
  message("No new data to commit")
}

