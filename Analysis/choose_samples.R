################################################################################
# requires objects: water, sites

sites <- data.table(sites)

seine_index <- sites[net %like% "seine" & revisit %like% "index", site_name]

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

