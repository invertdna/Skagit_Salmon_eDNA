# pick samples to test on
water <- load_water_samples("1_ujmAo0uw0gamLh7AGc7_qz8AXIoBM0We-CjSoHFG1U")

outcols <- c("lab_label", "event_id", "field_notes", "filter_notes")

badfield <- water[field_notes %like% "corresponding", outcols, with = FALSE]

water[,unique(filter_notes)]
badfilternotes <- c("forceps used to handle filter were definitely not clean", 
  "piece of filter broke, dropped, added back in", 
  "bottle not full: weight before - after = final; 761-93=668", 
  "tube cap fell on ground", 
  "piece of filter touched table", 
  "filter landed in trash right side up with paper underneath"
  )
badlab <- water[filter_notes %in% badfilternotes, outcols, with = FALSE]

outdat <- rbind(badfield, badlab)

outdat <- outdat[order(lab_label),]

EXPORT <- FALSE
if(EXPORT){
  fwrite(outdat, file = "../Data/test_samples.csv")
}
