################################################################################
library(data.table)

# requires objects: water, sites
source("load_sites.R")
source("load_water_samples.R")

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


source("load_dna.R")
to_extract <- to_pcr[ # from choose_samples.R
  !lab_label %in% DNA, 
  .(event_id, field_rep, filter_box, lab_label)
  ]
# fwrite(to_extract, "to_extract.csv")


