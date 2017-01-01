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

## Question: Across the United States, how have emissions from coal combustion-
## related sources changed from 1999–2008?

coal.levels <- levels(source.codes$EI.Sector)
coal.rows <- grep(pattern='Coal', x=coal.levels)
coal.fact <- select(source.codes, SCC, EI.Sector) %>%
  filter(EI.Sector %in% coal.levels[coal.rows])
coal.SCC <- as.character(coal.fact$SCC)

coal <- select(pm25, SCC, year, Emissions) %>%
  filter(SCC %in% coal.SCC) %>%
  group_by(year) %>%
  summarise(Emissions=sum(Emissions))

g <- ggplot(data=coal, aes(x=year, y=Emissions)) +
    ggtitle('Emissions of PM2.5 by Coal combustion-related sources\nacross the US [1998, 2008]') +
    xlab('Year') +
    ylab('PM2.5 (tons)')

png('plot4.png')
print(g + geom_line() + geom_point())
dev.off()
