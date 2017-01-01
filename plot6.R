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

## Reading the datasets
pm25 <- readRDS(file='summarySCC_PM25.rds')
source.codes <- readRDS(file='Source_Classification_Code.rds')

## Question: Compare emissions from motor vehicle sources in Baltimore City with
## emissions from motor vehicle sources in Los Angeles County, California
## (fips == "06037"). Which city has seen greater changes over time in motor
## vehicle emissions?

## Figuring out the codes for vehicle-related emissions. To do this, we search
## for the 'Vehicles' pattern.
motor.levels <- levels(source.codes$EI.Sector)
motor.rows <- grep(pattern='Vehicles', x=motor.levels)
motor.fact <- select(source.codes, SCC, EI.Sector) %>%
  filter(EI.Sector %in% motor.levels[motor.rows])
motor.SCC <- as.character(motor.fact$SCC)

## Getting the emission levels from Baltimore and LA county.
balt.vehicles <- select(pm25, SCC, Emissions, year, fips) %>%
  filter(fips == '24510') %>%
  filter(SCC %in% motor.SCC) %>% 
  group_by(year) %>%
  summarise(Emissions=sum(Emissions))

la.vehicles <- select(pm25, SCC, Emissions, year, fips) %>%
  filter(fips == '06037') %>%
  filter(SCC %in% motor.SCC) %>% 
  group_by(year) %>%
  summarise(Emissions=sum(Emissions))

## Merging the dataframes and attaching a new column to identify the sorurce.
loc <- factor(x=c(rep(0, times=4), rep(1, times=4)), labels=c('BALT', 'LA'))
vehicles <- cbind(rbind(balt.vehicles, la.vehicles), 'location'=loc)

g <- ggplot(data=vehicles, aes(x=year, y=Emissions, color=location)) + ggtitle('Emissions of PM2.5 by Vehicle-related sources in Baltimore and\nLos Angeles [1998, 2008]') + xlab('Year') + ylab('PM2.5 (tons)')

png('plot6.png')
print(g + geom_line() + geom_point())
dev.off()
