load_sites <- function(sites_file, gps.req = TRUE){
  #-------------------------------------------------------------------------------
  # Load Site Data
  sites_file <- "sites.csv"
  colname_lat <- "lat"
  colname_lon <- "lon"
  
  sites <- fread(
    file = file.path(data_dir, sites_file)
  )
  
  # exclude sites with no latitude data
  if(gps.req){
    sites <- sites[!is.na(sites$lat),]
  }
  
  return(sites)
  #-------------------------------------------------------------------------------
}
