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
blocks <- c(
  #  Nat="960x40+0+80",
  NatTests="170x40+50+80",
  NatCases="170x40+220+80",
  NatRecov="170x40+390+80",
  NatDeath="170x40+560+80",
  NatNewCases="170x40+730+80",
  WC="170x100+180+500",
  EC="170x100+430+480",
  NC="100x100+290+330",
  FS="170x100+400+350",
  KZN="170x100+610+400",
  NW="150x70+394+265",
  GP="168x100+300+140",
  MP="170x100+590+260",
  LP="170x100+550+150"
)
NatBlocks <- substr(names(blocks),1,3)=="Nat"


clean <- function(x) {
  if (FALSE) {
    x <- data[[1]]$NC
  }
  origx <- x
  x <- gsub(".*:","",x)    # remove every before the ":"
  x <- gsub(".*;","",x)    # sometimes this is a "the ";"
  x <- gsub("Deaths", "", x) # sometimes the colon is missing.
  x <- gsub(".*ases", "", x) # sometimes the colon is missing.
  x <- gsub("\\.", "", x)  # remove a "."
  x <- gsub(",", "", x)    # remove a ","
  x <- gsub("°", "", x)    # remove a "°"
  x <- gsub("§", "5", x)
  x <- gsub("S", "5", x)
  x <- gsub("\\$", "5", x) # sometimes a 5 is OCR'ed as an $
  if (length(x)>4 ) 
    x <- tail(x, 4)
  if (! length(x) %in% c(1,4)) {
    print(x)
    stop("Expecting 1 or 4 values, found above")
  }
  
  n <- as.numeric(x)
  if (any(faultyfield <- is.na(n))) {
    stop("String to numeric problem: ", x[faultyfield])
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

processDay <- function(img) {    # img <- imgs[1]
  
  image <- magick::image_read(img)
  if (FALSE) {
    magick::image_crop(image, "100x100+290+330")
    
  }
  
  OCRdata <- function(crop) {
    # crop <- blocks[4]    
    image2 <- magick::image_crop(image, crop)
    magick::image_write(image2, path = "temp.jpg", format = "jpg")
    
    
    tesseract::ocr("temp.jpg") %>% 
      gsub(" ", "", .) %>%
      strsplit("\n") %>%
      magrittr::extract2(1) %>% 
      magrittr::extract(.!="") %>%
      clean
    #tesseract::ocr_data("temp.jpg")
    
  }
  res <- list(Nat=sapply(blocks[NatBlocks], OCRdata),
              Prov=sapply(blocks[!NatBlocks], OCRdata, simplify = "array"))
  
  # add some final checks, and auto-fixing intelligence

  # check1: 
  check1 <- colSums(res$Prov[2:4, ])-res$Prov[1, ]
  check2 <- res$Nat[c(2,4,3)] - rowSums(res$Prov)[1:3]

  # try to auto-recover / fix the errors
  if (sum(check1!=0)==1 && 
      sum(check2!=0)<=1) {
    # there are errors on both checks, so we might be able to fix this....    
    fixProv <- which(check1!=0)
    if (sum(check2!=0)==0) {  # the first three variables are OK, so the error lies with ActiveCases
      # apply the fix to the Provincial Active cases number 
      message("Auto adjusting the Provincial data Active Cases for ", names(fixProv),": old nr: ",res$Prov[4, fixProv], ", new number: ", res$Prov[4, fixProv] - check1[fixProv])
      res$Prov[4, fixProv] <- res$Prov[4, fixProv] - check1[fixProv] 
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
      } else {
        stop("Cannot autofix checksum error:  Please investigate the numbers")
      }
    }
  } else {
    if (sum(check1!=0)>0 |
        sum(check2!=0)>0) {
      stop("Too many errors in the checksum figures.  Please investigate manually")
    }
  }

  check1 <- colSums(res$Prov[2:4, ])-res$Prov[1, ]
  check2 <- res$Nat[c(2,4,3)] - rowSums(res$Prov)[1:3]
  stopifnot(check1==0)
  stopifnot(check2==0)
  
  res
}

data <- lapply(imgs, processDay)

Nat <- sapply(data, getElement, "Nat")
Prov <- sapply(data, getElement, "Prov", simplify = "array")

dimnames(Prov)[[1]] <- c("Cases", "Deaths", "Recov", "Active")
  
if (!all(apply(Prov, c(1,3), sum)[1:3, ]==Nat[c(2,4,3), ])) {
  print(apply(Prov, c(1,3), sum)[1:3, ])
  print(Nat[c(2,4,3), ])
  stop("Mismatch between Prov and Nat")
}

# update the packages....
# install.packages("git2r")
px <- git2r::repository()
git2r::config(px, user.name = "krokkie", user.email = "krokkie@users.noreply.github.com")

CheckFile <- function(fn, data) {
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
  if (any(is.na(m))) {
    RecovAdd <- as.data.frame(t(data[colnames(recov)[3:11], rev(which(is.na(m))), drop=FALSE]))  # 3-11 == provinces
    RecovAdd$UNKNOWN <- 0
    RecovAdd$total <- colSums(data[colnames(recov)[3:11], rev(which(is.na(m))), drop=FALSE])
    RecovAdd$source <- "sacoronavirus_scrape_gdb"
    RecovAdd$YYYYMMDD <- gsub("-", "", rownames(RecovAdd))
    RecovAdd$date <- format(as.Date(rownames(RecovAdd), format = "%Y-%m-%d"), "%d-%m-%Y")
    #re-order colnames
    RecovAdd <- RecovAdd[, colnames(recov)]
    
    message('There are some new extra data from sacoronavirus.co.za -- appending this to the data files')
    recov <- rbind(recov, 
                   RecovAdd)
    
    write.csv(recov, fnx, 
              row.names = FALSE, quote = FALSE, na = "")
    
    git2r::add(px, paste0("data/covid19za_provincial_cumulative_timeline_", fn))
    git2r::commit(px, paste0("Missing ", fn, " provincial data added from sacoronavirus.co.za: ", paste0(RecovAdd$YYYYMMDD, collapse=", ")))
  } else {
    message("No new data for ", fn)
  }
  
}

CheckFile("recoveries.csv", Prov["Recov", , ])
CheckFile("deaths.csv", Prov["Deaths", , ])
CheckFile("confirmed.csv", Prov["Cases", , ])

# national level testing data
# data/covid19za_timeline_testing.csv  -- 
