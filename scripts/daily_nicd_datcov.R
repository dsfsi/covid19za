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
  if (!dir.exists(tempfol)) dir.create(tempfol, recursive = TRUE)
  pool <- curl::new_pool()
  sapply(seq_along(links), function(i) {   # i <- 1
    fn <- paste0(tempfol, "/", names(links)[i])
    if (!file.exists(fn)) {
      # different strategy: https://github.com/jeroen/curl/issues/148
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

# General function - White space (double space) string splitter
wsstrsplit <- function(s) {
  a <- trimws(strsplit(s, "  ")[[1]])
  a[!a==""]
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
  
  # Find the string "Ward of currently admitted patients"
  wardstr <- "Ward of currently admitted patients"
  # From 13-Jul-2020 onwards, we have two - total + private-only version. 
  wardpage <- head(which(regexpr(wardstr, x) > 0), 1)
  
  if (length(wardpage)!=1) {
    warning("Error finding Ward breakdown in file ", fn, '. Ignoring this breakdown')
    ward <- NULL
  } else {
    wardrow <- which(regexpr(wardstr, x2[[wardpage]]) > 0)
    stopifnot(length(wardrow)>0) 
    # assume this is always the leftmost block
    ward <- x2[[wardpage]][(wardrow+1):(wardrow+20)]

    # split header row into headings, and use the position of the second block to trim the lines
    blocks <- wsstrsplit(x2[[wardpage]][wardrow])
    block2startsat <- regexec(blocks[2], x2[[wardpage]][wardrow])[[1]]
    blockwidth <- block2startsat - 1 
    
    ward <- trimws(substr(ward,1,blockwidth))
    ward <- ward[ward!=""]
    
    # explicit end of table
    explicitendoftable <- regexec("epidemiological", ward) > 0    | 
                          regexec("age group and sex", ward) > 0
    if (any(explicitendoftable)) {
       ward <- ward[1:(which(explicitendoftable)[1]-1)]
    }
  }
   # Find the string "COVID-19 Surveillance" - use the date on this line.
  daterow <- which(regexpr("COVID-19.*Surveillance", x2[[1]]) > 0)    
  if (length(daterow)==0) {
    warning("File ", fn, " - unable to detect the date.  Ignoring this file.  ")
    table <- NULL
    date <- NULL
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
    table <- x2[[2]][tablestart:length(x2[[2]])]
    
    # older Format had charts below this table.   Wipe all of this
    stopTable <- which(regexpr("%ICU and %Ventilated", table) > 0)
    if (length(stopTable)>0) {
      table <- table[1:(stopTable-1)]
    }
  }

  list(table=table,   # Prov x PubPriv x Variable  breakdown 
       ward=ward,     # Ward-breakdown
       date=date)     # Date Top-Left
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
  if (UseCache) {
    save(file=cachefn, dataRaw)
  }
}

keep <- !sapply(dataRaw, FUN = function(x) is.null(x$date) )
message("Removing ", sum(!keep), " files - unable to parse")
dataRaw <- dataRaw[keep]

dates <- sapply(dataRaw, getElement, "date")
mapFile2Data <- dates
stopifnot(length(dates[is.na(dates)])==0)   # investigate different formats....
tables <- lapply(dataRaw, getElement, "table")
datesD <- as.Date(dates)
faultyYear <- as.integer(format(datesD, "%Y")) < 2020
datesD[faultyYear] <- datesD[faultyYear] + lubridate::years(2000)
dates <- as.character(datesD)
names(tables) <- dates
mapFile2Data[] <- dates

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
  # 
  x <- gsub("^ *1/1 *$", "", x)
  x <- gsub("^ */ *$", "", x)
  x <- gsub("^ *\UE115[/]* *$", "", x)
  x <- gsub("^ *\UE116 *$", "", x)
  
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
    message("About to ignore: ",trimws(x[rubbishLines]))
    x <- x[!rubbishLines]
  }
  x
}

tables2 <- lapply(tables, furtherCleaning)
# manual fix - Unknown prov - remove the two lines
if (length(tables2$`2021-02-19`)==32) {
  tables2$`2021-02-19` <- tables2$`2021-02-19`[-27:-28] 
}

fixColNames <- c(Facilitiesreporting="FacilitiesReporting",
                 Admissionstodate="AdmissionstoDate",
                 Deathstodate="DiedtoDate",
                 Currentlyadmitted="CurrentlyAdmitted",
                 CurrentinICU="CurrentlyinICU",
                 Currentlyventilated="CurrentlyVentilated")


ParseTable3 <- function(i) {    # x <- tables[500];   oldformat <- TRUE
  if (FALSE) {
    i <- 213
  }
  x <- tables2[[i]]
  numbers <- trimws(x)
  clean <-  numbers %>% 
    gsub("reporting[ ]*Admissions", "reporting\tAdmissions", .) %>%
    gsub("Facilities[ ]*Admissions", "Facilities\tAdmissions", .) %>% 
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
  
  problemRows <- which(sapply(clean, length)!=expectedNrCols)

  # some exceptions
  if(problemRows[1]==1 & 
     length(clean[[1]])==expectedNrCols+1) {
    clean[[1]] <- clean[[1]][1:expectedNrCols]   # one extra table heading without data  
  }

  problemRows <- which(sapply(clean, length)!=expectedNrCols)
  
  if (length(problemRows)==1) {
    if (clean[[problemRows]][1]=="Public" & 
        (clean[[problemRows-1]][1]=="WesternCape" |    # either one or two lines prior
         clean[[problemRows-2]][1]=="WesternCape")) {
      # fix the WC missing CurrentVentilated+CurrentOxy in Public
      insertNA <- clean[[1]] %in% c("CurrentlyOxygenated", "CurrentlyVentilated")
      fix <- cumsum(!insertNA) # expand this
      fix[insertNA] <- NA
      clean[[problemRows]] <- clean[[problemRows]][fix]  
    }
  }
  
  problemRows <- sapply(clean, length)!=expectedNrCols
  
  if (sum(problemRows)>0) {
    print(sapply(clean, length))
    stop("Not square dataframe: ", names(tables2)[i], " x ", i)
  }
  
  a <- do.call(rbind, clean)
  colnames(a) <- a[1, ]
  
  # fix some of these variable names
  m <- match(colnames(a), names(fixColNames))
  if (any(!is.na(m))) {
    colnames(a)[!is.na(m)] <- unname(fixColNames)[m[!is.na(m)]]
  }

  a <- a[-1, ]
  # rownames(a) <- a[, 1]
  # a <- a[, -1]
  res <- as.data.frame(a, stringsAsFactors = FALSE)
  res$Owner <- "Total"
  res$Owner[res$Province=="Private"] <- "Priv"
  res$Owner[res$Province=="Public"]  <- "Pub"
  
  res$Province[res$Owner!="Total"] <- NA
  res$Province <- zoo::na.locf(res$Province)
  
  res$Date <- names(tables2)[i]
  flat <- reshape2::melt(res, id=c("Province", "Owner", "Date"), na.rm = TRUE, stringsAsFactors = FALSE)
}

validWardLabels <- c("ICU", "High Care", "Isolation", "General")
fixWardLabels <- c(`General Ward`="General",
                   `Intensive Care Unit`="ICU")

cleanWards <- function(i) {   # i <- 122
  # l <- wards[[1]]
  tryCatch({
    l <- wards[[i]]
    origl <- l
    delline <- regexec("Currently in Hospital:", l) > 0
    if (any(delline)) {
      l <- l[!delline]
    }
    labels <- wsstrsplit(tail(l,1))  
    
    m <- match(names(fixWardLabels), labels)
    if (any(!is.na(m))) {
      # replace certain Ward Labels....
      labels[m[!is.na(m)]] <- unname(fixWardLabels)[!is.na(m)] 
    }
    
    problemLabels <- ! labels %in% validWardLabels
    if (any(problemLabels)) {
      message("Problematic labels detected - ignoring: ", paste0(labels[problemLabels], collapse=", "))
      labels <- labels[!problemLabels]
    }
    # remove the labels part    
    l <- l[1:(length(l)-1)]
    
    # the remainder should be numbers only.  Ignore any non-numbers. 
    notnumber <- is.na(as.integer(gsub("K", "E3", l)))
    if (any(notnumber)) {
      message("ignoring the following labels - not numeric: ", paste0(l[notnumber], collapse=","))
      l <- l[!notnumber]
    }
    
    # check if  
    if (length(l)!=length(labels)) {
      stop("Ward breakdown error for ", dataRaw[[i]]$date, " # ", i)
    }
    CleanWards <- setNames(as.integer(gsub("K", "E3", l)), labels)
    CleanWards[validWardLabels]
  }, error=function(e) {
    stop("error in Cleanwards: ", i, " ", dataRaw[[i]]$date)
  })
}

wards <- lapply(dataRaw, getElement, "ward")
wardsarr <- sapply(setNames(seq_along(wards), dates), cleanWards, simplify = "array")
names(dimnames(wardsarr)) <- c("variable", "Date")
wardflat <- reshape2::melt(wardsarr, as.is = TRUE, na.rm = TRUE)
wardflat$variable <- paste0("CurrentWard", gsub(" ", "", wardflat$variable))
wardflat$Province <- "Total"
wardflat$Owner <- "Total"   # Priv/Pub/Tot

message("Running final cleaning step: ")
tables3 <- lapply(seq_along(tables2), ParseTable3 )

allHospital <- data.table::rbindlist(c(tables3, list(wardflat)), use.names=TRUE)   # only the latest 10 

# read the current database of hospitalization
entireHospital <- read.csv("data/covid19za_provincial_raw_hospitalization.csv") %>%
                  data.table::setDT()

# remove the overlap between the history, and the newly processed files,
# and finally append the newly processed files' details into the entireDB
entireHospital <- rbind(entireHospital[!Date %in% unique(allHospital$Date)], allHospital) 
# order by date
entireHospital <- entireHospital[order(entireHospital$Date), ]

# save raw data into a raw flat file
write.csv(entireHospital, "data/covid19za_provincial_raw_hospitalization.csv", 
          row.names = FALSE, quote = FALSE)

#TODO: update the data/nicd_hospital_surveillance_data.csv file
selectedIndicators <- read.csv("data/nicd_hospital_surveillance_data.csv")
selectedIndicators$source <- trimws(selectedIndicators$source)   # the CSV is not 100% standard - using a ", " as the sep
#unique(entireHospital$variable)

Admissions <- entireHospital[variable=="AdmissionstoDate" & Owner=="Total", c("Date", "value", "Province")] %>%
  reshape2::dcast(Date ~ Province)

TotVars <- c("CurrentlyAdmitted", "CurrentlyinICU", "CurrentWardHighCare", "CurrentWardGeneral", "Dischargedtodate", "DiedtoDate")
RestOfVars <- entireHospital[variable %in% TotVars & Owner=="Total" & Province=="Total", c("Date", "variable", "value")] %>%
  reshape2::dcast(Date ~ variable)

NewHospData <- merge(Admissions, RestOfVars, by="Date")
# colnames(NewHospData)
# colnames(selectedIndicators)

colrename <- c(#date="Date",   # calculated field
               YYYYMMDD="Date",   # almost, without the dashes  
               total_admissions="Total",
               WC="WesternCape",
               EC="EasternCape",
               GP="Gauteng",
               KZN="KwaZulu-Natal",
               LP="Limpopo",
               FS="FreeState",
               MP="Mpumalanga",
               NW="NorthWest",
               NC="NorthernCape",
               current_num_in_hospital="CurrentlyAdmitted",
               general="CurrentWardGeneral",
               high_care="CurrentWardHighCare",
               ICU="CurrentlyinICU",
               #isolation=NA,   # discontinued
               #total_heathcare_workers_admitted=NA,  # discontinued
               num_discharged_alive="Dischargedtodate",
               hospital_deaths="DiedtoDate"
              )
# Check if colnames match
if (!all(unname(colrename) %in% colnames(NewHospData))) {
  stop("The colnames of the selectedIndicators changed.   Update and fix please!")
}

# reorder according to colrename spec
NewHospData <- NewHospData[, unname(colrename)]
colnames(NewHospData) <- names(colrename)

# source lookup
mapFile2Data <- unlist(mapFile2Data)
m <- match(NewHospData$YYYYMMDD, unname(mapFile2Data))
NewHospData$localfile[!is.na(m)] <- names(mapFile2Data)[m[!is.na(m)]]
NewHospData$source[!is.na(m)] <- unname(links[NewHospData$localfile[!is.na(m)]])

# fix the date formats
NewHospData$date <- as.Date(NewHospData$YYYYMMDD) %>% format.Date("%d-%m-%Y")
NewHospData$YYYYMMDD <- gsub("-", "", NewHospData$YYYYMMDD)

# additional time points
datesOverlap <- selectedIndicators$YYYYMMDD %in% NewHospData$YYYYMMDD
datesOverlapNew <- NewHospData$YYYYMMDD %in% selectedIndicators$YYYYMMDD 

# investigate differences in the data
if (FALSE) {
  commoncols <- intersect(colnames(NewHospData), colnames(selectedIndicators) )[-1][-17:-18]
  selectedIndicators[datesOverlap, commoncols] - 
    NewHospData[datesOverlapNew, commoncols]
  # conclusion:  the data is very similar.   There are a couple of differences - most probably copy & paste errors by hand.
  # strategy would be to replace this with the scraped data.
}

# append new time points
dateExists <- NewHospData$YYYYMMDD %in% selectedIndicators$YYYYMMDD

if (any(!dateExists)) {
  # we have some new data!
  commoncols <- intersect(colnames(NewHospData), colnames(selectedIndicators))
                        
  AppendData <- NewHospData[!dateExists, commoncols]
  missingCols <- setdiff(colnames(selectedIndicators), colnames(NewHospData))
  # append missing colums
  lapply(missingCols, function(cn) { 
    AppendData[[cn]] <<- NA
    TRUE
  })
  
  selectedIndicators <- rbind(selectedIndicators, AppendData)
  # reorder by date
  selectedIndicators <- selectedIndicators[order(selectedIndicators$YYYYMMDD), ]
}

if (any(dateOverlap)) {
  m <- match(selectedIndicators$YYYYMMDD[dateOverlap], NewHospData$YYYYMMDD)
  
  overwriteCols <- intersect(colnames(selectedIndicators), colnames(NewHospData))
  skipcols <- c("source", "YYYYMMDD", "date", "total_admissions")
  overwriteCols <- overwriteCols[! overwriteCols %in% skipcols ]

  selectedIndicators[dateOverlap, overwriteCols] <- 
    NewHospData[m, overwriteCols]
}



# finally write the new dataset out again....
write.table(selectedIndicators, file = "data/nicd_hospital_surveillance_data.csv",
            row.names = FALSE, quote = FALSE, sep = ", ", na = "")


if (FALSE) {
  # What does the Gauteng numbers look like?
  entireHospital[Owner=="Total" & Province == "Gauteng" & Date > "2021-11-20", c("Date", "variable", "value")] %>%
    reshape2::dcast(Date ~ variable)
  
  
  icuGP <- entireHospital[Owner=="Total" & Province == "Gauteng" & variable=="CurrentlyinICU", c("Date", "value")] 
  icuGP <- tail(icuGP, 100)
  plot(x=as.Date(icuGP$Date), y=as.numeric(icuGP$value), type="l", xlab = "", ylab="NUmber of ICU beds", main = "Gauteng Hospitalization")
  
  allGP <- entireHospital[Owner=="Total" & Province == "Gauteng", c("Date", "variable", "value")] %>%
    reshape2::dcast(Date ~ variable)

  plot(x=as.Date(allGP$Date), y=as.numeric(allGP$CurrentlyAdmitted), type="l", xlab = "", ylab="NUmber of ICU beds", main = "Gauteng Hospitalization")
  
}
# 

px <- git2r::repository()
git2r::config(px, user.name = "krokkie", user.email = "krokkie@users.noreply.github.com")

s <- git2r::status(px, staged = FALSE, untracked = FALSE)
if (length(s$unstaged)>0) {   # we have files that we can commit
  # if git2r::checkout()
  fns <- c("data/covid19za_provincial_raw_hospitalization.csv", 
           "data/nicd_hospital_surveillance_data.csv")
  if (any(fns %in% s$unstaged)) {
    message("New data added - commiting now")
    lapply(fns, FUN=function(fn) { 
      git2r::add(px, fn)
      TRUE
    })
    git2r::commit(px, "Daily hospitalization data from NICD refreshed")  
  } else {
    message("No new data")
  }
} else {
  message("No changes - nothing to commit")
}


