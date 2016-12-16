#-------------------------------------------------------------------------------
# get dna for each event
dna_by_event <- split(qpcr_data[,"Quantity"], qpcr_data[,"event_id"])
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# get sum of counts of chinook by sampling event
chinook_by_event <- sapply( split(
  catch_chinook[,3:5], catch_chinook[,"event_id"]
  ), sum)
plot(chinook_by_event)
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# which events have both?
events_in_both <- intersect(names(dna_by_event), names(chinook_by_event))

#-------------------------------------------------------------------------------
# arrange for plotting
dna <- dna_by_event[events_in_both]
fish <- chinook_by_event[events_in_both]

plot_dat <- data.frame(
event = names(unlist(dna)), 
dna = unlist(dna), 
fish = rep(fish, times = sapply(dna, length))
)

plot(plot_dat$fish + 0.1, plot_dat$dna + 0.00001, log = "xy")