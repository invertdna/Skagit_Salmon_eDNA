################################################################################
library(data.table)

# requires objects: water, sites
sites <- load_sites("../Data/sites.csv")
water <- load_water_samples("1_ujmAo0uw0gamLh7AGc7_qz8AXIoBM0We-CjSoHFG1U")

site.dt <- data.table(sites)

seine_index <- site.dt[net %like% "seine" & revisit %like% "index", site_name]

# DT <- water[site_name %in% seine_index, ]
DT <- water[site_name %in% seine_index & date > "2016-12-31",] #unique(date), by = site_name

DT <- DT[!field_notes %like% "no corresponding survey",]

site_dates <- DT[, unique(date), by = site_name]

# which sites have >4 sampling events in 2017?
goodsites <- site_dates[,.N > 4, by = site_name][,site_name[V1]]

to_pcr <- water[
  !field_notes %like% "no corresponding survey" & 
  sample_type %like% "water-marine" & 
  date > "2016-12-31" & 
  site_name %in% goodsites, 
  .(site_name, datetime, event_id, field_rep, field_notes, filter_box, lab_label, 
    filter_notes, preservative_ml)
]

# fwrite(to_pcr, "to_pcr.csv")


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
