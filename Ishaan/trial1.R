#RUSSIAN EXAMPLE

setwd("C:/Users/Hello/Dropbox/ADBI_Big_Data/Experiment/Ishaan")

require (stats)

media.data <- read.csv("search_trends_PHL20_EN.csv.csv")
m <- rowMeans(media.data[,2:21])
m <- ts(m, start = c(2010, 1), end = c(2020,12), frequency = 12)
m

k <- decompose(m)
k$figure
plot(k)
data.frame(m)