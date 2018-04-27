# !!! SET WORKING DIRECTORY TO THIS PROJECT'S SUBDIRECTORY 'Analysis'
# Set directories from which to read/write data and write figures
INTERACTIVE <- FALSE
if(INTERACTIVE){
  analysis_dir <- dirname(file.choose()) # choose this script file
  setwd(analysis_dir)
} else {
  analysis_dir <- getwd()
}
data_dir <-  file.path("..", "Data")
fig_dir <- file.path("..", "Figures")

################################################################################
# LOAD FUNCTIONS
################################################################################

R_files <- list.files(path = "functions", pattern = "\\.R$", full.names = TRUE)
sapply(R_files, source)

################################################################################
# INSTALL PACKAGES
################################################################################
package_req <- read.table("packages_required.txt", stringsAsFactors = FALSE)[,1]
for(package in package_req){
	if(! package %in% installed.packages()){
		install.packages(package)
	}
}
