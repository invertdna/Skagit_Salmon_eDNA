library(readxl)

excel_file <- '/Users/jimmy.odonnell/Downloads/eDNA sample sites 2017 rh.xlsx'
xls <- read_excel(excel_file)

sites <- load_sites("../Data/sites.csv")

library(magrittr)

# modify column names
names(xls) %>% 
  gsub("SRSC DB Site Name", "Site.Name.SRSC", ., fixed = TRUE) %>% 
  gsub("Corrected Location in Bay (SiteGroup)", "Site.Group.SRSC", 
       ., fixed = TRUE) -> names(xls)
names(xls)[names(xls) == "Site"] <- "Site.Name.NOAA"
names(xls)[names(xls) == "SiteGroup"] <- "Site.Group.NOAA"
names(xls)[names(xls) == "Sampling Gear"] <- "Sampling.Gear"

DT <- data.table(xls)
DT[is.na(Site.Group.SRSC), Site.Group.SRSC := Site.Group.NOAA]

cols2keep <- c("Site.Name.NOAA", "Site.Group.NOAA", 
  "Site.Name.SRSC", "Site.Group.SRSC", "Sampling.Gear")
DT[,Sampling.Gear := tolower(Sampling.Gear)]
DT[Sampling.Gear %like% "beach seine", Sampling.Gear := "seine"]
DT[Sampling.Gear %like% "none", Sampling.Gear := "none"]
DT[,Sampling.Gear]
cols3keep <- setdiff(cols2keep, "Sampling.Gear")
# view site names and groups
unique(DT[ , cols3keep, with = FALSE])

comparefull <- function(v1, v2){
  element <- sort(union(v1, v2))
  in.v1 <- element %in% v1
  in.v2 <- element %in% v2
  in.both <- element %in% v1 & element %in% v2
  df <- data.frame(element, in.v1, in.v2, in.both)
  return(df)
}
comparefull(sites$site_name, unique(DT$Site.Name.NOAA))
comparefull(sites$NameSRSC, unique(DT$Site.Name.SRSC))

# isolate site names
sitenames_full <- rbindlist(list(unique(DT[,.(Site.Name.NOAA, Site.Name.SRSC)]), 
      sites[,.(site_name, NameSRSC)]))
sitenames_full <- unique(sitenames_full[order(Site.Name.NOAA),])
EXPORT <- FALSE
if(EXPORT){
  fwrite(sitenames_full, "../Data/site_names.csv")
}
