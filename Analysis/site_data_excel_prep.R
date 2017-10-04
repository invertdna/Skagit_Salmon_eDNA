install.packages("readxl")
library(readxl)

excel_file <- '/Users/jimmy.odonnell/Downloads/eDNA sample sites 2017 rh.xlsx'

xls <- read_excel(excel_file)

library(magrittr)

# modify column names
names(xls) %>% 
  gsub("SRSC DB Site Name", "Site.Name.SRSC", ., fixed = TRUE) %>% 
  gsub("Corrected Location in Bay (SiteGroup)", "Site.Group.SRSC", 
       ., fixed = TRUE) -> names(xls)

names(xls)[names(xls) == "Site"] <- "Site.Name.NOAA"
names(xls)[names(xls) == "SiteGroup"] <- "Site.Group.NOAA"

# isolate site groups
Site.Groups <- unique(xls[,c('Site.Group.NOAA', 'Site.Group.SRSC')])
Site.Groups$Site.Group.SRSC
Site.Group.SRSC <- Site.Groups$Site.Group.SRSC
Site.Group.NOAA <- Site.Groups$Site.Group.NOAA

Site.Group.SRSC %>% is.na %>% Site.Group.NOAA[.] -
for(i in 1:length(Site.Groups$Site.Group.SRSC)){
  if(is.na())
}

# isolate site names
Site.Names <- unique(xls[,c('Site.Name.NOAA', 'Site.Name.SRSC')])

Site.Groups
