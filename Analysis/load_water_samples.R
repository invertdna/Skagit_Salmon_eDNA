# load water samples
#-------------------------------------------------------------------------------

# requires an object "catch_metadata"

head(catch_metadata)

water <- read.csv(file.path(data_dir, "water_samples.csv"), stringsAsFactors = FALSE)

water[,"lab_label"]

water$site_abbr <- site_trans[match(water[,"site_name"], site_trans[,3]), 1]

water$event_id <- paste(
  water$site_abbr, 
  gsub("-", "", substr(water$date_collected, 3, 10)), sep = "-"
  )


water[,"site_name"]
water[,""]
water[,]

