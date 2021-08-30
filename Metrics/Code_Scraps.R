# Code scraps

# Create the data
# Convert dta to csv two ways
mig.dta <- read_dta(file = "keywords_ext2.dta")
write.csv(mig.dta, file = "Mig_Data1.csv")
mig.data1 <- read.csv("Mig_Data1.csv")
#Data1 has a redundant column

convert("keywords_ext2.dta", "Mig_Data2.csv")

mig.data2 <- read.csv("Mig_Data2.csv")

wbdi.data <- read.csv("WBDI.csv")

long_dat <- wbdi.data %>% gather(Year,Value,X2010:X2020)

head(long_dat)

head(wbdi.data)

## Write summary on the disk and collect saved file names
fileName <- file.path(tempdir(), "WBDI2.csv")
write.csv(long_dat, "WBDI2.csv")
print(ret)
file.show(ret[1])

mig.data3 <- read.csv("Mig_Data3.csv")
#kgz.data3<- read.csv("Kgz_data.csv")

