setwd("~/Dropbox (bearecon)/ADBI_Big_Data/Experiment/Metrics")
import pandas as pd
data = pd.io.stata.read_stata('my_stata_file.dta')
from pytrends.request import TrendReq
import pandas as pd
import time

install.packages("rio")
library("rio")
library(haven)
library(tidyverse)
library(lfe)
library(stargazer)

# Convert dta to csv two ways
mig.dta <- read_dta(file = "keywords_ext2.dta")
write.csv(mig.dta, file = "Mig_Data1.csv")
mig.data1 <- read.csv("Mig_Data1.csv")
convert("keywords_ext2.dta", "Mig_Data2.csv")
mig.data2 <- read.csv("Mig_Data2.csv")

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