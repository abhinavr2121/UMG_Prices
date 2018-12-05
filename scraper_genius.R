library('rvest')
library('httr')
library('stringr')
library('curl')
library('purrr')

months <- c("january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december")
years <- 2016 : 2017

data <- data.frame()
print("Scraping Genius.com data...")
for(i in years) {
  sub.data <- data.frame()
  for(j in months) {
    print(paste(j, i))
    url <- paste('https://genius.com/Genius-', j, '-', i, '-album-release-calendar-annotated', sep = "")
    webpage <- read_html(url)
    sub <- html_nodes(webpage, '.referent') %>% html_text()
    sub.d <- data.frame(predata = sub, month = rep(j, length(sub)), year = i)
    sub.data <- rbind(sub.data, sub.d)
  }
  data <- rbind(data, sub.data)
}

print("Normalizing Genius.com scrape data...")
for(i in 1 : length(data$predata)) {
  splits <- strsplit(as.character(data$predata[i]), " - ")[1]
  data$artist[i] <- splits[[1]][1]
  data$album[i] <- splits[[1]][2]
}

safe_get <- safely(GET)

data <- subset(data, select = 4 : length(data))
data$release_date <- rep("", length(data$artist))
data$tracks <- rep(0, length(data$artist))
data$album_type <- rep("", length(data$artist))
data$markets <- rep(0, length(data$artist))

print("Data harvesting from Spotify Web Api...")
album <- tolower(data$album) %>% str_replace_all(" ", "%20") %>% str_replace_all("/", "") %>% str_replace_all(":", "")
for(i in 1 : length(album)) {
  print(paste(i, "of", length(album)))
  url <- paste("https://api.spotify.com/v1/search?q=", album[i], "&type=album&limit=1", sep = "")
  req <- safe_get(url, add_headers(Authorization = "Bearer BQCftKmLjBW9TzmTwnex700pCPJ2LYYbludMQpv4YDEPsE1_Ocsf3cGDdk-6idkx2s_aDDt_ohEPpPnKWbspPPk08hXjG5LMLJHI_nFX0BA5nmdoT5jP7PrDgbj8zMl_u4ley74N7XO_na9Fvfo9"))
  if(!is.null(req$result)) {
    cont <- content(req$result)
    if(class(cont[1]) == "list") {
      if(length(cont$albums$items) > 0) {
        if(cont$albums$items[[1]]$release_date_precision == "day") {
          data$release_date[i] <- cont$albums$items[[1]]$release_date
          data$tracks[i] <- cont$albums$items[[1]]$total_tracks 
          data$album_type[i] <- cont$albums$items[[1]]$album_type
          data$markets[i] <- length(cont$albums$items[[1]]$available_markets)
        }
        else {
          data$release_date[i] <- NA
          data$tracks[i] <- NA
          data$album_type[i] <- NA
          data$markets[i] <- NA
        }
      }
    }
    else {
      data$release_date[i] <- NA
      data$tracks[i] <- NA
      data$album_type[i] <- NA
      data$markets[i] <- NA
    }
  }
  else {
    data$release_date[i] <- NA
    data$tracks[i] <- NA
    data$album_type[i] <- NA
    data$markets[i] <- NA
  }
}
data <- subset(data, !is.na(data$release_date))
data <- subset(data, !(data$release_date == ""))
print("Complete.")
