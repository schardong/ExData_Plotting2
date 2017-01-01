library(dplyr)
library(ggplot2)

## Downloading the dataset, if necessary.
url.dataset <- 'https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip'
filepath <- 'exdata.zip'

if (!file.exists('Source_Classification_Code.rds') | !file.exists('summarySCC_PM25.rds')) {
    download.file(url=url.dataset, destfile=filepath)
    unzip(filepath)
    file.remove(filepath)
}

## Reading the dataset and grouping it by year and type.
pm25 <- readRDS(file='summarySCC_PM25.rds')

balt <- filter(pm25, fips=='24510') %>%
  group_by(year, type) %>%
  summarise(Emissions=sum(Emissions)) %>%
  mutate(type=as.factor(type))

## Plotting the data.
g <- ggplot(data=balt, aes(x=year, y=Emissions, color=type)) +
      ggtitle('Emissions of PM2.5 by year/type in the city of Baltimore') +
      xlab('Year') +
      ylab('PM2.5 (tons)')

png('plot3.png')
print(g +
      geom_line() +
      geom_point())
dev.off()
