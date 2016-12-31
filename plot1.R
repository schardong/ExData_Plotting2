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

by.year <- group_by(pm25, year) %>%
  summarise(Emissions=sum(Emissions))

## Plotting the total PM2.5 emissions by year.
png('plot1.png')
plot(Emissions ~ year,
     data=by.year,
     type='l',
     main='Emissions of PM2.5 by year',
     xlab='Year',
     ylab='PM2.5 (tons)')
with(data=by.year,
     points(x=year,
            y=Emissions,
            pch=19))
dev.off()
