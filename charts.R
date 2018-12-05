library(caret)
library(caTools)
library(ggplot2)
library(ggthemes)
library(Metrics)

data <- read.csv('ml.csv', stringsAsFactors = F)
data$release_date <- as.Date(data$release_date)
data$target <- factor(data$target)

data <- data[data$release_date > "2015-01-01", ]
data <- data[order(data$release_date), ]

p <- ggplot(data, aes(x = tracks, fill = target)) + geom_histogram(binwidth = 3, color = 'black') + xlab("Number of Tracks") + ylab("Frequency") + ggtitle("Distribution of Tracks") + theme_gdocs()
p

p2 <- ggplot(data, aes(x = album_type, fill = target)) + geom_bar(color = 'black') + xlab("Album Type") + ylab("Frequency") + ggtitle("Distribution of Album Types") + theme_gdocs()
p2

p3 <- ggplot(data, aes(x = release_date, fill = target)) + geom_histogram(binwidth = 60, color = 'black') + xlab("Release Date") + ylab("Frequency") + ggtitle("Distribution of Release Dates") + theme_gdocs()
p3