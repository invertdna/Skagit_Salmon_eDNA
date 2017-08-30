#-------------------------------------------------------------------------------
# Load Site Data
sites_file <- "sites.csv"
colname_lat <- "lat"
colname_lon <- "lon"

sites <- read.csv(
  file = file.path(data_dir, sites_file), 
  stringsAsFactors = FALSE
)

# exclude sites with no latitude data
sites <- sites[!is.na(sites$lat),]
#-------------------------------------------------------------------------------
