# Author: gerh@rd.co.za
# Script that scrapes the sacoronavirus.co.za website
# https://sacoronavirus.co.za/covid-19-daily-cases/
library(magrittr)

# on the gitlab runner, the working folder is /home/runner/work/covid19za/covid19za
# print(getwd())
if (interactive()) {  # for debug purposes
    setwd(file.path(dirname(rstudioapi::getActiveDocumentContext()$path),'/..'))
}

rss <- xml2::as_list(xml2::read_xml(httr::GET("https://sacoronavirus.co.za/feed/")))[[1]][[1]]
junk <- sapply(rss, function(x) (is.null(x$category)) || (unlist(x$category)!="Daily Cases"))
rss <- rss[!junk]
origtitle <- sapply(rss, getElement, "title") %>%
  gsub(".*\\((.*)\\)", "\\1", .) %>% 
  trimws()

# use the publication date when we cannot derive the date from the publication automatically.
pubDate <- unname(unlist(sapply(rss, getElement, "pubDate"))) %>%
  as.Date.character(format = "%A, %d %B %Y") %>%
  as.character()

# fix mistakes here
origtitle <- gsub("Tuesday 09 August 2021", "Tuesday 10 August 2021", origtitle)

names(rss) <- origtitle %>%   # only keep that in the brackets
  as.Date.character(format = "%A %d %B %Y") %>%
  as.character()

if (any(missing <- is.na(names(rss)))) {  # if I cannot auto-detect the date
  warning("Error translating '", paste0(origtitle[missing], collapse="','"), "' into a precise date.") 
  warning("Will use the PublicationDate as the authoritive date: ", paste0(pubDate[missing], collapse=", "))
  names(rss)[ is.na(names(rss))] <- pubDate[missing]
}

if (any(problemdate <- names(rss) != pubDate)) {
  combined <- as.data.frame(list(Title=origtitle, dateFromTitle=names(rss), datePublished=pubDate, issue=problemdate))
  print(combined[problemdate, ])
  warning("Will use the publication date here instead....")
  names(rss)[problemdate] <- pubDate[problemdate]
}

if (any(duplicated(names(rss)))) {
  stop("Duplicates found in the title of the daily cases - please check these")
}

rss <- lapply(rss, function(x) unlist(x$encoded))

getsrc <- function(x) {   
  if (is.null(attr(x, "src"))) {
    if (is.list(x)) {
      getsrc(x[[1]])  # recursive
    } else {
      NA
    }
  } else {
    attr(x, "src")
  }
}

imgs <- sapply(rss, function(x) getsrc(xml2::as_list(xml2::read_html(x))))
# filter from a specific date onwards, as the images might have moved since then, and the positions are no longer valid.
imgs["2021-12-02"] <- "https://sacoronavirus.co.za/wp-content/uploads/2021/12/02-nov-map.jpg"
imgs <- imgs[names(imgs) > "2021-12-02"]

blocks <- c(
  #  Nat="960x40+0+80",
  NatTests="170x40+50+80",
  NatCases="170x40+220+80",
  NatRecov="170x40+390+80",
  NatDeath="170x40+560+80",
  NatNewCases="170x40+730+80",
  WC="170x100+180+480",
  EC="170x100+390+500",
  NC="170x110+190+330", 
  FS="170x100+430+370",
  KZN="170x100+610+404",
  NW="170x100+390+265",
  GP="168x100+300+150",
  MP="170x100+590+260",
  LP="220x100+550+150"
)
NatBlocks <- substr(names(blocks),1,3)=="Nat"

dataAllGood <- TRUE

clean <- function(x, msgposition="") {
  if (FALSE) {
    x <- data[[1]]$NC
  }
  origx <- x
  x <- gsub(".*:","",x)    # remove every before the ":"
  x <- gsub(".*;","",x)    # sometimes this is a "the ";"
  x <- gsub("Deaths", "", x) # sometimes the colon is missing.
  x <- gsub("Recoveries", "", x)
  x <- gsub(".*ases", "", x) # sometimes the colon is missing.
  x <- gsub("§", "5", x)
  x <- gsub("£", "1", x)
  x <- gsub("\\|", "1", x)
  x <- gsub("S", "5", x)
  x <- gsub("\\$", "5", x) # sometimes a 5 is OCR'ed as an $
  x <- gsub('”', "", x)
  x <- gsub("\\.", "", x)  # remove a "."
  x <- gsub(",", "", x)    # remove a ","
  x <- gsub("°", "", x)    # remove a "°"
  
  x <- gsub("[^0-9]", "", x)    # remove any non-numeric character.....
  if (length(x)>4 ) 
    x <- tail(x, 4)
  if (! length(x) %in% c(1,4)) {
    print(x)
    stop("Expecting 1 or 4 values, found above at ", msgposition)
  }
  
  n <- as.numeric(x)
  if (any(faultyfield <- is.na(n))) {
    print(x)
    message("String to numeric problem: '", paste0(x[faultyfield], collapse="','"), "'")
    if (sum(faultyfield)==1) {
      n[faultyfield] <- 0
      message("Found an empty field.   Assume this is a zero...")
    } else {
      stop("Too many errors - cannot continue.")
    }
  } 
  if (length(n)==4) {
    if (sum(n[2:4])!=n[1]) {
      #print(n)
      #print()
      message("Checksum failed in OCR step.  Will attempt recover later: ", paste0(origx, collapse="  "))
    }
  }
  n
}

processDay <- function(img, runAutomated=TRUE) {    # img <- imgs[1]
  print(basename(img))
  image <- magick::image_read(img)
  if (FALSE) {
    magick::image_crop(image, blocks['FS'])
    magick::image_crop(image, "160x45+30+180")   #WxH+X+Y
  }

#  engine <- tesseract::tesseract(language = "eng",
#                                 options = list(tessedit_char_whitelist = "CaseDthAciv:0123456789"))

  ocrdata <- tesseract::ocr_data(image)
  ocrdata[ocrdata$confidence > 80, ]
  FindProv <- function(prov) {   # prov="Limpopo"
    i <- which(ocrdata$word %in% prov)
    if (length(i)>0) {
      ocrdata[i, c("word", "bbox")]
    } else {
      NA
    }
  }
  
  # FindProv(c("WESTERN", "EASTERN", "NORTHERN", "FREE", "KWAZULU-NATAL", "WEST", "GAUTENG", "MPUMALANGA", "Limpopo"))

  OCRdata <- function(crop) {   # crop <- blocks['NatActive']
    # crop <- "170x100+430+490"    
    negate <- substr(crop,1,1)=="*" 
    if (negate) {
      crop <- substr(crop,2,nchar(crop))
      image2 <- magick::image_negate(magick::image_crop(image, crop))
    } else {
      image2 <- magick::image_crop(image, crop)
    } 
    
    magick::image_write(image2, path = "temp.jpg", format = "jpg")

    tesseract::ocr("temp.jpg") %>%   # , engine = engine
      gsub(" ", "", .) %>%
      strsplit("\n") %>%
      magrittr::extract2(1) %>% 
      magrittr::extract(.!="") %>%
      clean(crop)
    #tesseract::ocr_data("temp.jpg")
    
  }
  res <- list(Nat=sapply(blocks[NatBlocks], OCRdata),
              Prov=sapply(blocks[!NatBlocks], OCRdata, simplify = "array"))
  
  # add some final checks, and auto-fixing intelligence

  check2 <- res$Nat[c(2,4,3)] - rowSums(res$Prov)[1:3]
  # check1: provincial details are internally consistent within a province.
  check1 <- colSums(res$Prov[2:4, ])-res$Prov[1, ]  # active + deaths + recov = cases 
  # check2: sum(province) == national, on variable level 

  if (sum(check2!=0)==1) {
    variable <- which(check2!=0)
    
    fixProv <- which(abs(sum(check2)) == abs(check1) )
    if (length(fixProv)==1) {
      message("Two checksums failed with the same difference:  auto-fixing ", 
              names(fixProv), " x ", names(variable), 
              ": old nr: ",res$Prov[variable, fixProv], 
              ", new number: ", res$Prov[variable, fixProv] + check2[variable])
      res$Prov[variable, fixProv] <- res$Prov[variable, fixProv] + check2[variable] 
      check2 <- res$Nat[c(2,4,3)] - rowSums(res$Prov)[1:3]
      check1 <- colSums(res$Prov[2:4, ])-res$Prov[1, ]
    }
  }
  
  # try to auto-recover / fix the errors
  if (sum(check1!=0)==1 && 
      sum(check2!=0)<=1) {
    # there are errors on both checks, so we might be able to fix this....    
    fixProv <- which(check1!=0)
    if (sum(check2!=0)==0) {  # the first three variables are OK, so the error lies with ActiveCases
      # apply the fix to the Provincial Active cases number 
      message("Auto adjusting the Provincial data Active Cases for ", names(fixProv),": old nr: ",res$Prov[4, fixProv], ", new number: ", res$Prov[4, fixProv] - check1[fixProv])
      res$Prov[4, fixProv] <- res$Prov[4, fixProv] - check1[fixProv] 
      check1 <- colSums(res$Prov[2:4, ])-res$Prov[1, ]
      check2 <- res$Nat[c(2,4,3)] - rowSums(res$Prov)[1:3]
    } else {
      #one-one error: 
      if (abs(sum(check1))==
          abs(sum(check2))) {
        variable <- which(check2!=0)
        message("Two checksums failed with the same difference:  auto-fixing ", 
                names(fixProv), " x ", names(variable), 
                ": old nr: ",res$Prov[variable, fixProv], 
                ", new number: ", res$Prov[variable, fixProv] + check2[variable])
        res$Prov[variable, fixProv] <- res$Prov[variable, fixProv] + check2[variable] 
        check1 <- colSums(res$Prov[2:4, ])-res$Prov[1, ]
        check2 <- res$Nat[c(2,4,3)] - rowSums(res$Prov)[1:3]
      } else {
        if (runAutomated) res <- NULL
        message("Cannot autofix checksum error:  Please investigate the numbers")
      }
    }
  }
  # single variable problem, across multiple provinces.   11-Dec-2021
  if ((sum(check1)==sum(check2)) & sum(check2!=0)==1 ) {  
    fixProv <- which(check1!=0)
    variable <- which(check2!=0)
    message("Auto adjusting multi-prov for ", paste0(names(fixProv), collapse=",")," single variable: ", 
            "old nr: ",paste0(res$Prov[variable, fixProv], collapse=","), 
            ", new number: ", paste0(res$Prov[variable, fixProv] + check1[fixProv], collapse=","))
    res$Prov[variable, fixProv] <- res$Prov[variable, fixProv] + check1[fixProv] 
    check1 <- colSums(res$Prov[2:4, ])-res$Prov[1, ]
    check2 <- res$Nat[c(2,4,3)] - rowSums(res$Prov)[1:3]
  } else {
    if (sum(check1!=0)>0 |
        sum(check2!=0)>0) {
      if (runAutomated) res <- NULL
      message("Too many errors in the checksum figures.  Please investigate manually: ", sum(check1!=0), " vs ", sum(check2!=0))
    }
  }

  if (!is.null(res)) {
    check1 <- colSums(res$Prov[2:4, ])-res$Prov[1, ]
    check2 <- res$Nat[c(2,4,3)] - rowSums(res$Prov)[1:3]
    
    dataAllGood <<- dataAllGood &  
                     all(check1==0) &
                     all(check2==0)
      
    if (sum(check1!=0)>0 |
        sum(check2!=0)>0) {
      if (runAutomated) {
        res <- NULL
        message("Ignoring ", basename(img), ", because check1=", check1, ", and check2=", check2)
      }
    }
  }
  
  res
}

if (FALSE) {
  data <- lapply(imgs, processDay, runAutomated=TRUE)
}
data <- lapply(imgs, processDay, runAutomated=!interactive())
# remove 
data <- data[!sapply(data, is.null)]
stopifnot(length(data)>0)

Nat <- sapply(data, getElement, "Nat")
Prov <- sapply(data, getElement, "Prov", simplify = "array")

dimnames(Prov)[[1]] <- c("Cases", "Deaths", "Recov", "Active")
  
if (!all(p <- (pp <- (apply(Prov, c(1,3), sum)[1:3, ]))==(pn <- Nat[c(2,4,3), ]))) {
  pd <- apply(p, 2, all)   # problem date
  #which(!pd)
  print(pp[, !pd, drop=FALSE])
  print(pn[, !pd, drop=FALSE])
  warning("Mismatch between Prov and Nat")
  dataAllGood <- FALSE
}

# update the packages....
# install.packages("git2r")
px <- git2r::repository()
git2r::config(px, user.name = "krokkie", user.email = "krokkie@users.noreply.github.com")

CheckFile <- function(fn, data, allowChanges = TRUE) {
  if (FALSE) {
    fn <- "recoveries.csv"
    data <- Prov["Recov", , ]
    
    fn <- "deaths.csv"
    data <- Prov["Deaths", , ]
  }  
  if (any(errdate <- is.na(colnames(data)))) {
    print(colnames(data))
    stop("Unknown dates in data: NA")
  }
  
  recov <- read.csv(fnx <- paste0('data/covid19za_provincial_cumulative_timeline_', fn), 
                    stringsAsFactors = FALSE)
  # find these dates in the data file....
  m <- match(format(as.Date(colnames(data), format = "%Y-%m-%d"), "%d-%m-%Y"), recov$date)
  oldData <- recov[m[!is.na(m)], rownames(data)]
  commitMsg <- "" 
    
  chgs <- ((newData <- t(data[,!is.na(m), drop=FALSE]))-oldData) != 0
  if (any(chgs) & allowChanges) {
    message("Applying some historic revisions")
    recov[m[!is.na(m)], rownames(data)] <- newData
    recov[m[!is.na(m)], "total"] <- unname(rowSums(newData))
    commitMsg <- "Some historic revisions added"
  }
  
  if (any(is.na(m))) {
    RecovAdd <- as.data.frame(t(data[colnames(recov)[3:11], rev(which(is.na(m))), drop=FALSE]))  # 3-11 == provinces
    RecovAdd$UNKNOWN <- 0
    RecovAdd$total <- colSums(data[colnames(recov)[3:11], rev(which(is.na(m))), drop=FALSE])
    RecovAdd$source <- "sacoronavirus_scrape_gdb"
    RecovAdd$YYYYMMDD <- gsub("-", "", rownames(RecovAdd))
    RecovAdd$date <- format(as.Date(rownames(RecovAdd), format = "%Y-%m-%d"), "%d-%m-%Y")
    #re-order colnames
    RecovAdd <- RecovAdd[, colnames(recov)]
    
    commitMsg <- paste0("Missing ", fn, " provincial data added from sacoronavirus.co.za: ", paste0(RecovAdd$YYYYMMDD, collapse=", "))
    message('There are some new extra data from sacoronavirus.co.za -- appending this to the data files')
    recov <- rbind(recov, 
                   RecovAdd)
    recov <- recov[order(recov$YYYYMMDD), ]
  } else {
    message("No new data for ", fn)
  }
  write.csv(recov, fnx, 
            row.names = FALSE, quote = FALSE, na = "")
  
  if (dataAllGood) {
    if (paste0("data/covid19za_provincial_cumulative_timeline_", fn) %in% unname(unlist(git2r::status()$unstaged))) {
      git2r::add(px, paste0("data/covid19za_provincial_cumulative_timeline_", fn))
      git2r::commit(px, commitMsg)
    } else {
      message(fn, " - nothing to commit")
    } 
  } else {
    warning("Have not automatically committed the changes - please check manually before committing")
  }
  
}

CheckFile("recoveries.csv", Prov["Recov", , ])
CheckFile("deaths.csv", Prov["Deaths", , ])
CheckFile("confirmed.csv", Prov["Cases", , ], allowChanges = FALSE)

# national level testing data
# data/covid19za_timeline_testing.csv  -- 
if (!dataAllGood) {
  if (interactive()) {
    system("git gui", wait=FALSE)
  } else {
    stop("The automated scraper could not update the numbers automatically.
Please run this script manual, and check the numbers.")
  }
}
