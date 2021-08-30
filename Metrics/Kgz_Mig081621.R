setwd("~/Documents/Github/ADBI_Big_Data/Metrics")

library(rio)
library(haven)
library(tidyverse)
library(lfe)
library(stargazer)

mig.data3 <- read.csv("Mig_Data4.csv")

#mig.data4 <- coljoin(mig.data3,kgz.data3,)

#initialize variables
gdppcl=log(mig.data3$"NY.GDP.MKTP.KD"/mig.data3$"SP.POP.TOTL")
ul=log(.01*mig.data3$"SL.UEM.TOTL.ZS")
reml=log(mig.data3$"BX.TRF.PWKR.CD.DT")
lpil=log(mig.data3$"LP.LPI.INFR.XQ")
mobl=log(mig.data3$"mobile_destination")
#mobl=log(mig.data3$"IT.CEL.SETS.P2")
netl=log(mig.data3$"internet_destination")
airppcl=log(mig.data3$"airtr_quality_destination")
#airppcl=log(mig.data3$"IS.AIR.PSGR"/mig.data3$"SP.POP.TOTL")
migl=log(mig.data3$migration)
aze <- mig.data3$AZE
deu <- mig.data3$DEU
rus <- mig.data3$RUS
tjk <- mig.data3$TJK
ukr <- mig.data3$UKR
usa <- mig.data3$USA

ogdppcl=log(mig.data3$"oNY.GDP.MKTP.KD"/mig.data3$"oSP.POP.TOTL")
oul=log(.01*mig.data3$"oSL.UEM.TOTL.ZS")
oreml=log(mig.data3$"oBX.TRF.PWKR.CD.DT")
olpil=log(mig.data3$"oLP.LPI.INFR.XQ")
omobl=log(mig.data3$"mobile_origin")
#omobl=log(mig.data3$"oIT.CEL.SETS.P2")
onetl=log(mig.data3$"internet_origin")
#onetl=log(mig.data3$"oIT.NET.USER.ZS")
oairppcl=log(mig.data3$"airtr_origin")
#oairppcl=log(mig.data3$"oIS.AIR.PSGR"/mig.data3$"oSP.POP.TOTL")

words <- rowMeans(mig.data3[,c(109,150)])

work <- mig.data3[,111]
passport <- mig.data3[,118]
employment <- mig.data3[,127]
jobkg <- mig.data3[,128]
job <- mig.data3[,129]


# Macromodel without Destination Dummies
# Terrible
fit <- lm(migl ~ gdppcl + ogdppcl + ul + oul)
summary(fit)

# Macromodel with Dummies
# Signs correct but Origin GDP and Destination unemployment insignificant
fit <- lm(migl ~ aze + deu + rus + ukr + usa + gdppcl + ogdppcl + ul + oul)
summary(fit)

# Macromodel - Destination dummies, Destination GDP, and Origin Unemployment
# Best so far
fit <- lm(migl ~ aze + deu + rus + ukr + usa  + gdppcl  + oul)
summary(fit)

# Lets try infrastructure - logistics
# Strange sign - logistics improvement reduces migration?
fit <- lm(migl ~ gdppcl + ogdppcl + ul + oul + lpil + olpil)
summary(fit)

# Lets try infrastructure - Mobile
# Destination mobile density important
fit <- lm(migl ~ gdppcl + ogdppcl + ul + oul + mobl + omobl)
summary(fit)

# Lets try infrastructure - Net quality
# Nothing
fit <- lm(migl ~ gdppcl + ogdppcl + ul + netl + onetl)
summary(fit)

# Lets try infrastructure - Air travel quality
# Nothing
fit <- lm(migl ~ gdppcl + ogdppcl + ul + airppcl + oairppcl)
summary(fit)

# Here is the basic problem - the country dummies proxy infrastructure differences
fit <- lm(migl ~ aze + deu + rus + ukr + usa + gdppcl + ogdppcl + ul + airppcl + oairppcl)
summary(fit)

# Incremental effects of search words - overall average
# Not much happening with average of all word results
fit <- lm(migl ~ aze + deu + rus + ukr + usa  + gdppcl  + oul + words)
summary(fit)

# Incremental effects of search words - selected
# Not much happening again
fit <- lm(migl ~ aze + deu + rus + ukr + usa  + gdppcl  + oul + work + passport + employment + jobkg + job)
summary(fit)

fit <- lm(migl ~ aze + deu + rus + ukr + usa  + gdppcl  + oul + jobkg + job)
summary(fit)

fit <- lm(migl ~ aze + deu + rus + ukr + usa  + gdppcl  + oul + jobkz)
summary(fit)






stargazer(mig.data1,type="text")
datab <- read.csv("https://raw.githubusercontent.com/dwrh/Thesis_SBui/main/data/NO2.csv")
names(datab) <- c("NW", "W","SW", "N", "NO2", "S", "NE", "E", "SE", "date", "month", "quarter", "name", "year", "bridge", "ferry","pcr","dpp","pp","after")
datab$date <- as.Date(datab$date)
datab$bridge_ferry <- datab$bridge + datab$ferry
reg1 <- felm(NO2 ~ bridge + year| month, datab)
reg2 <- felm(NO2 ~ bridge + year| month + name, datab)
reg3 <- felm(NO2 ~ bridge + year| quarter, datab)
reg4 <- felm(NO2 ~ bridge + year| quarter + name, datab)
reg5 <- felm(NO2 ~ bridge + year + ferry| month, datab)
reg6 <- felm(NO2 ~ bridge + year + ferry| month + name, datab)
reg7 <- felm(NO2 ~ bridge + year + ferry + bridge_ferry| month + name, datab)
stargazer(reg1,reg2,reg3,reg4, type = "text")
stargazer(reg5,reg6,reg7, type = "text")