# !!! SET WORKING DIRECTORY TO THIS PROJECT'S SUBDIRECTORY 'Analysis'
# Set directories from which to read/write data and write figures
INTERACTIVE <- FALSE
if(INTERACTIVE){
  analysis_dir <- dirname(file.choose()) # choose this script file
  setwd(analysis_dir)
} else {
  analysis_dir <- getwd()
}
data_dir <- file.path("..", "Data")
fig_dir <- file.path("..", "Figures")

#-------------------------------------------------------------------------------
# LOAD FUNCTIONS

R_files <- list.files(path = "functions", pattern = "\\.R$", full.names = TRUE)
sapply(R_files, source)


#-------------------------------------------------------------------------------
# LOAD DATA

# read in the sites
sites_file <- "sites.csv"
colname_lat <- "lat"
colname_lon <- "lon"

sites <- read.csv(
  file = file.path(data_dir, sites_file), 
  stringsAsFactors = FALSE
)

# exclude sites with no latitude data
sites <- sites[!is.na(sites$lat),]
