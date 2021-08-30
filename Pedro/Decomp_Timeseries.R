# Example of time serise decomposition
# Referennce: https://nwfsc-timeseries.github.io/atsa-labs/sec-tslab-decomposition-of-time-series.html

#set wd
setwd("~/Dropbox\ (bearecon)/ADBI_Big_Data/Experiment")

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
m
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

#ADBI Example - Other Countries
media.data <- read.csv("KYR_Media_Overseas.csv")
m <- media.data[,2]
m <- ts(m, start = c(2004, 5), end = c(2021,5), frequency = 12)
m

k <- decompose(m)
k$figure
plot(k)

# A more intensive examples
# NOT RUN {
require(graphics)

plot(stl(nottem, "per"))
plot(stl(nottem, s.window = 7, t.window = 50, t.jump = 1))

plot(stllc <- stl(log(co2), s.window = 21))
summary(stllc)
## linear trend, strict period.
plot(stl(log(co2), s.window = "per", t.window = 1000))

## Two STL plotted side by side :
stmd <- stl(mdeaths, s.window = "per") # non-robust
summary(stmR <- stl(mdeaths, s.window = "per", robust = TRUE))
op <- par(mar = c(0, 4, 0, 3), oma = c(5, 0, 4, 0), mfcol = c(4, 2))
plot(stmd, set.pars = NULL, labels  =  NULL,
     main = "stl(mdeaths, s.w = \"per\",  robust = FALSE / TRUE )")
plot(stmR, set.pars = NULL)
# mark the 'outliers' :
(iO <- which(stmR $ weights  < 1e-8)) # 10 were considered outliers
sts <- stmR$time.series
points(time(sts)[iO], 0.8* sts[,"remainder"][iO], pch = 4, col = "red")
par(op)   # reset
# }
