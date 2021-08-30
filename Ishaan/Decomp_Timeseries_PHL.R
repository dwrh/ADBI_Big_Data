# Example of time serise decomposition
# Reference: https://nwfsc-timeseries.github.io/atsa-labs/sec-tslab-decomposition-of-time-series.html

#set wd
setwd("C:/Users/Hello/Dropbox/ADBI_Big_Data/Experiment/Ishaan")

require (stats)

#Simple Example
require(graphics)


## Simple example
x <- c(-50, 175, 149, 214, 247, 237, 225, 329, 729, 809,
       530, 489, 540, 457, 195, 176, 337, 239, 128, 102, 232, 429, 3,
       98, 43, -141, -77, -13, 125, 361, -45, 184)
x <- ts(x, start = c(1951, 1), end = c(1958, 4), frequency = 4)
m <- decompose(x)
m$figure
plot(m)
## seasonal figure: 6.25, 8.62, -8.84, -6.03
round(decompose(x)$figure / 10, 2)
# }

#ADBI Example - Russia
media.data <- read.csv("KYR_Media_Overseas.csv")
m <- media.data[,3]
m <- ts(m, start = c(2004, 5), end = c(2021,5), frequency = 12)
m

# Default Decomposition is Additive
k <- decompose(m)
#k <- decompose(m,type = "multiplicative")

k$figure
plot(k)

#Ishaan Example - PHL 20 most relevant words

media.data <- read.csv("search_trends_PHL20_EN.csv.csv")
m <- rowMeans(media.data[,2:21])
m <- ts(m, start = c(2010, 1), end = c(2020,12), frequency = 12)
m

k <- decompose(m)
k$figure
plot(k)
