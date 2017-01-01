library(dplyr)

## Downloading the dataset, if necessary.
url.dataset <- 'https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip'
filepath <- 'exdata.zip'

if (!file.exists('Source_Classification_Code.rds') | !file.exists('summarySCC_PM25.rds')) {
    download.file(url=url.dataset, destfile=filepath)
    unzip(filepath)
    file.remove(filepath)
}

## Reading the dataset and grouping it by year.
pm25 <- readRDS(file='summarySCC_PM25.rds')

## Have total emissions from PM2.5 decreased in the Baltimore City, Maryland
## (fips == "24510") from 1999 to 2008?

balt <- filter(pm25, fips=='24510') %>%
  group_by(year) %>%
  summarise(Emissions=sum(Emissions))

png('plot2.png')
plot(Emissions ~ year,
     data=balt,
     type='l',
     main='Emissions of PM2.5 by year in the city of Baltimore',
     xlab='Year',
     ylab='PM2.5 (tons)')
with(data=balt,
     points(x=year,
            y=Emissions,
            pch=19))
dev.off()
