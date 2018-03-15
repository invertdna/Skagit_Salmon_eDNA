################################################################################
library(data.table)

# requires objects: water, sites
sites <- load_sites("../Data/sites.csv")
water <- load_water_samples("1_ujmAo0uw0gamLh7AGc7_qz8AXIoBM0We-CjSoHFG1U")

# get index sites that were seined, except for boat ramp because it is up the river.
seine_index <- sites[
  net == "seine" & 
    revisit == "index" &
    site_name != "Wylie Boat Ramp", 
  site_name]

# extra visits: Lone 5 16/17; Goat 6 19/21; Straw 5 16/17
events_to_drop <- c('LOTRPT-170516', 'GOATIS-170619', 'STRPTN-170516')

# get samples taken at index seine sites in 2017
seine_samples <- water[
  (site_name %in% seine_index) & 
    !(event_id %in% events_to_drop) &
    (date > '2017-01-01') & 
    (sample_type == 'water-marine'), # this excludes DIH2O samples taken to sites as controls
  .(date, time, site_name,lab_label,event_id) # only include these columns
][order(site_name)]

# fwrite(seine_samples, file = 'seine_samples.csv')

# this is a tally of the number of samples collected at those sites
seine_samples[ , 
  list('site_name' = unique(site_name), 'n_samples' = uniqueN(lab_label)), 
  by = event_id]

# these are the events of interest. might be useful later.
target_events <- seine_samples[,unique(event_id)]

# this yields a tally of the number of samples that have been extracted from each of the target events
dna <- load_dna()
dt <- merge(
  seine_samples, 
  dna[,.(date_extracted, extraction_label)], 
  by.x = 'lab_label', by.y = 'extraction_label', all.x = TRUE)
dt[ , extracted := !is.na(date_extracted)]
dna_tally <- dt[ ,.(n_extracted = sum(extracted)), by = event_id][order(event_id)]
to_extract_180315 <- dna_tally[n_extracted < 3][ , list(event_id, to_extract = 3-n_extracted)]

# pick those from this list:
seine_samples[event_id %in% to_extract_180315[,event_id]]

# this yields a tally of the number of samples that have been cleaned from each of the events
clean <- load_cleaned()
clean[,date.clean := Date]
dt <- merge(
  seine_samples, 
  clean[,.(date.clean, Sample)], 
  by.x = 'lab_label', by.y = 'Sample', all.x = TRUE)
dt[,cleaned := !is.na(date.clean)]
clean_tally <- dt[,.(n_clean = sum(cleaned)), by = event_id][order(event_id)]
clean_tally[n_clean < 3]

# originally, I eliminated any that had 'no corresponding survey' in field_notes, or that had fewer than 5 visits
# to_pcr <- water[
#   !field_notes %like% "no corresponding survey" & 
#   sample_type %like% "water-marine" & 
#   date > "2016-12-31" & 
#   site_name %in% goodsites, 
#   .(site_name, datetime, event_id, field_rep, field_notes, filter_box, lab_label, 
#     filter_notes, preservative_ml)
# ]

# fwrite(to_pcr, "to_pcr.csv")

# which are already cleaned and ready for qpcr 2018-03-01
cleaned <- load_cleaned()
forqpcr180301 <- to_pcr[lab_label %in% cleaned$Sample, 
  .(site_name, datetime, event_id, field_rep, lab_label)
  ]
EXPORT <- FALSE
if(EXPORT){
  fwrite(forqpcr180301[,'lab_label'], 'samples_qpcr_180301.csv')
}


DNA <- load_dna()
to_extract <- to_pcr[ # from choose_samples.R
  !lab_label %in% DNA, 
  .(event_id, field_rep, filter_box, lab_label)
  ]
# fwrite(to_extract, "to_extract.csv")

################################################################################
# choose samples for qPCR
################################################################################
source("load_qpcr.R")
DNA <- load_dna()
cleaned <- load_cleaned()

qpcr <- qpcr_data
done.ext <- unique(DNA[["extraction_label"]])
done.clean <- cleaned[,Sample]
done.qpcr <- unique(qpcr[["template_name"]])

# which events are already in qpcr data
done.events <- water[ lab_label %in% done.qpcr, unique(event_id)]

# find events that are not already in qpcr, but that *have* been extracted, and are field samples
to_qpcr <- water[ 
  !(event_id %in% done.events) & 
    lab_label %in% done.ext & 
    datetime > "2017-01-01" & 
    sample_type == "water-marine", 
       # .(event_id, lab_label)
       ]
to_qpcr <- to_qpcr[event_reps > 2]

to_qpcr <- to_qpcr[!(field_notes %like% "mesh"),]
to_qpcr <- to_qpcr[!(filter_notes %like% "trash"),]

# need 1 less:
to_qpcr <- to_qpcr[-1,]

# fwrite(to_qpcr, file = "to_qpcr.csv")

samples <- sort(to_qpcr[,lab_label])
# write.table(samples, file = "samples.txt", quote = FALSE, row.names = FALSE, col.names = FALSE)
