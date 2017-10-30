# load water samples
#-------------------------------------------------------------------------------
# requires an object "catch_metadata" ?does it?

library(googlesheets)
library(data.table)
library(lubridate)

env_samples_gs_key <- "1_ujmAo0uw0gamLh7AGc7_qz8AXIoBM0We-CjSoHFG1U"
# key before google drive snafu: "1IzJG3jaZCNXu6GNtx0ltsyJn0D8bprWs6NcYXCTGg_A"
water <- data.table(gs_read(gs_key(env_samples_gs_key)))

water_file <- file.path(data_dir, "water_samples.csv")
water_saved <- fread(water_file)
# TODO bug; column classes are auto-set differently by fread and gs_read
if(!identical(water_saved, water)){
  warning('local and remote data are not the same. You might want to refresh.')
}
water_refresh <- FALSE
if(water_refresh){
  fwrite(water, water_file)
}

# Add a POSIX compliant date-time variable
water$datetime <- lubridate::ymd_hms(paste(water$date, maketime(water$time)), 
                          tz = "America/Los_Angeles")

# add event ID
source("load_sites.R")
water <- merge(water, sites[, c("site_name", "Abbr")], by = "site_name", all.x = TRUE)
water$event_id <- paste(
  water$Abbr, 
  format(water$date, "%y%m%d"), sep = "-"
)

