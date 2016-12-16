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
# collate data on catch and DNA for each bottle
plot_dat_bottle <- data.frame(
  event_id = bottle_to_event, 
  bottle   = names(dna_by_bottle_med), 
  dna      = dna_by_bottle_med,
  fish     = chinook_by_event[bottle_to_event]
)[!is.na(bottle_to_event),] # remove rows of standards
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
model_linear_summary <- summary(model_linear)

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
plot_name <- "DNA_by_seine_chinook"

EXPORT <- FALSE

if(!exists("legend_text")){legend_text <- list()}
legend_text[plot_name] <- {"
Concentration of Chinook Salmon DNA plotted against Chinook Salmon captured in beach seines at 10 sites in Skagit Bay.
At each site, 2 beach seines and 3-4 water samples were collected. 
The total number of Chinook across seine surveys is plotted here. 
DNA was extracted from each bottle and used as template in 3 independent qPCRs; 
the median of these is taken, and the site concentration is taken as the median of these estimates.
A linear model demonstrates that the intercept cannot be distinguished from 0 (p = 0.596), 
while the number of fish (log(x+1)) was a significant predictor of DNA concentration (p = 0.000762).
"}

if(EXPORT){
  pdf_file    <- file.path(fig_dir, paste(plot_name, ".pdf", sep = ""))
  legend_file <- file.path(fig_dir, paste(plot_name, "_legend.txt", sep = ""))
  writeLines(legend_text[[plot_name]], con = legend_file)
  pdf(file = pdf_file, width = 5, height = 5) #, width = 8, height = 3
}

par(mar = c(4,5,1,1))
plot(
  x = log(plot_dat$fish + 1), 
  y = plot_dat$dna, 
  axes = FALSE, 
  xlab = "Total Chinook", 
  ylab = expression(paste("Concentration Chinook DNA (pg/", mu, "L)", sep = "")), 
  pch = 19, col = "black", 
  las = 1
  )

# add points for each bottle
points(
  x = plot_dat_bottle$fish, 
  y = plot_dat_bottle$dna
)

xaxis_ticks <- c(0, 5, 10, 25, 50, 100, 200)

axis(1, 
  at = log(xaxis_ticks + 1), 
  labels = xaxis_ticks
  )

axis(2, las = 1)

abline(model_linear, col = "cornflowerblue", lwd = 2)

box()

if(EXPORT){
  dev.off()
}
#-------------------------------------------------------------------------------
