library(purrr)

data <- read.csv('spotify.csv', stringsAsFactors = F)
viv <- read.csv('vivendi.csv', stringsAsFactors = F)

data$release_date <- as.Date(data$release_date)

a <- data$release_date
data$target <- 0
for(i in 1 : length(data$album)) {
  counter <- 0
  print(paste(i, "of", length(data$album)))
  while(is_empty(viv$date[viv$date == a[i]])) {
    a[i] <- a[i] + counter
    counter <- counter + 1
    if(counter > 3) {
      break
    }
  }
  if(counter <= 3) {
    data$target[i] <- ifelse(viv$change[7 + which(viv$date == a[i])] > 3, 1, 0)
  }
  else {
    data$target[i] <- NA
  }
}

data <- data[complete.cases(data), ]
write.csv(data, 'preprocess.csv', row.names = F)
