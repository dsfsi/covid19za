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
  
  message(substr(x$`Table 3. Weekly`[1],80,120))
  t3 <- x$`Table 3. Weekly`[1:30] 
  
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
    
    dates <- strsplit(t3[2], "  ") %>%
      extract2(1) %>%
      extract(. != "") %>%
      trimws()
    colnames(res) <- c(t(outer(X=dates, Y=c("Cases", "Positive"), FUN = function(x,y) paste0(y,"|",x))))
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
    colnames(res) <- c(t(outer(X=dates, Y=c("Cases", "Positive"), FUN = function(x,y) paste0(y,"|",x))))
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


