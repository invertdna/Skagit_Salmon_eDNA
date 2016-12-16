# requires these objects: qpcr_data, catch_chinook


#-------------------------------------------------------------------------------
# get median dna per bottle across the three replicate qPCR reactions
dna_by_bottle <- split(qpcr_data[,"QuantBackCalc"], qpcr_data[,"template_name"])

log1 <- function(x){
  return(log(x + 0.00001))
}

log_dna_by_bottle <- lapply(dna_by_bottle, log1)
par(mar = c(4, 5, 1, 1))
stripchart(
  x = lapply(dna_by_bottle, log1), 
  method = "jitter", 
  pch = 21, 
  las = 1
  )
stripchart(lapply(lapply(dna_by_bottle, log1), mean), col = "red", add = TRUE)
stripchart(lapply(lapply(dna_by_bottle, log1), median), col = "blue", , pch = 2, add = TRUE)

dna_by_bottle_med <- sapply(dna_by_bottle, median)
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# calculate the median estimate for each event from the bottle estimates
bottle_to_event <- qpcr_data[
  match(names(dna_by_bottle_med), qpcr_data[,"template_name"]),
  "event_id"
]

dna_by_event_med <- sapply(split(dna_by_bottle_med, bottle_to_event), median)
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# get dna for each event
dna_by_event <- split(qpcr_data[,"QuantBackCalc"], qpcr_data[,"event_id"])
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# get sum of counts of chinook by sampling event
chinook_by_event <- sapply( split(
  catch_chinook[,3:5], catch_chinook[,"event_id"]
  ), sum)
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# which events have both?
events_in_both <- intersect(names(dna_by_event), names(chinook_by_event))
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# arrange for plotting and modelling
dna  <- dna_by_event_med[events_in_both]
fish <- chinook_by_event[events_in_both]

plot_dat <- data.frame(
  event = names(unlist(dna)), 
  dna   = unlist(dna) * 1000, 
  fish  = rep(fish, times = sapply(dna, length))
)
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# assess the fit of a linear model
model_linear <- lm(dna ~ log(fish + 1), data = plot_dat)
summary(model_linear)

x_pred <- 0:max(plot_dat$fish)

con95 <- predict(
    object   = model_linear,
    newdata  = data.frame(fish = log(x_pred + 1)),
    interval = "confidence",
    level    = 0.95
  )

#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# requires plot_dat, with columns named "dna" and "fish"
plot(
  x = log(plot_dat$fish + 1), 
  y = plot_dat$dna, 
  axes = FALSE, 
  xlab = "Total Chinook", 
  ylab = expression(paste("Concentration Chinook DNA (pg/", mu, "L)", sep = "")), 
  las = 1
  )
xaxis_ticks <- c(0, 5, 10, 25, 50, 100, 200)

axis(1, 
  at = log(xaxis_ticks + 1), 
  labels = xaxis_ticks
  )

axis(2, las = 1)

abline(model_linear, col = "cornflowerblue", lwd = 2)

box()
#-------------------------------------------------------------------------------




