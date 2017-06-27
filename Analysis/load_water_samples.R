# load water samples
#-------------------------------------------------------------------------------
# requires an object "catch_metadata" ?does it?

library(googlesheets)
library(data.table)

# water_file <- file.path(data_dir, "water_samples.csv")
# water <- read.csv(water_file, stringsAsFactors = FALSE)

env_samples_gs_key <- "1IzJG3jaZCNXu6GNtx0ltsyJn0D8bprWs6NcYXCTGg_A"

water <- data.table(gs_read(gs_key(env_samples_gs_key)))

water <- merge(water, sites[, c("site_name", "Abbr")], by = "site_name", all.x = TRUE)

water$event_id <- paste(
  water$Abbr, 
  format(water$date, "%y%m%d"), sep = "-"
  )


