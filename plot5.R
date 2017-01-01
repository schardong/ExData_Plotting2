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
source.codes <- readRDS(file='Source_Classification_Code.rds')

## Question: How have emissions from motor vehicle sources changed from
## 1999–2008 in Baltimore City?

motor.levels <- levels(source.codes$EI.Sector)
motor.rows <- grep(pattern='Vehicles', x=motor.levels)
motor.fact <- select(source.codes, SCC, EI.Sector) %>%
  filter(EI.Sector %in% motor.levels[motor.rows])
motor.SCC <- as.character(motor.fact$SCC)

balt.vehicles <- select(pm25, SCC, Emissions, year, fips) %>%
  filter(fips == '24510') %>%
  filter(SCC %in% motor.SCC) %>% 
  group_by(year) %>%
  summarise(Emissions=sum(Emissions))

g <- ggplot(data=balt.vehicles, aes(x=year, y=Emissions)) +
  ggtitle('Emissions of PM2.5 by Vehicle-related sources in Baltimore') +
  xlab('Year') +
  ylab('PM2.5 (tons)')

png('plot5.png')
g + geom_line() + geom_point()
dev.off()
