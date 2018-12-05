library('rvest')

data <- read.csv('preprocess.csv', stringsAsFactors = F)
url <- "https://en.wikipedia.org/wiki/List_of_Universal_Music_Group_artists"
webpage <- read_html(url)
sub <- html_nodes(webpage, 'a') %>% html_text()
artists <- sub[21 : 862]

data <- data[data$artist %in% artists, ]
write.csv(data, 'ml.csv', row.names = F)
