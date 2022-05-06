checkFile <- function(fn) {
  if (FALSE) fn <- "data/covid19za_provincial_cumulative_timeline_recoveries.csv"
  
  data <- read.csv(fn)
  rownames(data) <- data$date
  data$date <- NULL
  data$source <- NULL
  m <- as.matrix(data)
  
  d <- m[2:nrow(m), ] - m[1:(nrow(m)-1), ]
  if (any(d<0)) {
    # negative  
    print(reshape2::melt(d)[which(d<0), ])
    warning("Found negative values in ", fn, " - see above")    
  }
  
  d <- rowSums(m[, 2:11]) - m[, 12]
  
  sumTotErr <- d[d != 0]
  if (length(sumTotErr) > 0) {
    print(sumTotErr)
  }
}
  
checkFile("data/covid19za_provincial_cumulative_timeline_deaths.csv")
checkFile("data/covid19za_provincial_cumulative_timeline_recoveries.csv")
