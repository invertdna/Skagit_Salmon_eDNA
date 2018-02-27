# requires these objects: qpcr_data, catch_chinook

# load water
water <- load_water_samples()

# load qpcrs
R1 <- load_qpcr(
  qpcr_data_file = "../Data/qpcr/CKCO3-161209/results/results_table.txt", 
  sample_sheet_file = "../Data/qpcr/CKCO3-161209/setup/sample_sheet.csv", 
  std_conc = 9.36
)

# check extra columns: R2[,.(no_lab_error, note) ]
# remove c("no_lab_error", "note") before rbind
cols_to_remove <- c('no_lab_error', 'note')
R2 <- load_qpcr(
  qpcr_data_file = "../Data/qpcr/CKCO3-161214/results/results_table.txt", 
  sample_sheet_file = "../Data/qpcr/CKCO3-161214/setup/sample_sheet.csv", 
  std_conc = 9.36
)[ 
  # exclude samples with lab error:
  no_lab_error == TRUE , ][, 
  (cols_to_remove) := NULL]

# rbind qpcrs
qpcr_data <- rbind(R1, R2)

# add event id to qpcr
qpcr_data <- merge(x = qpcr_data, 
  y = water[,c("event_id", "lab_label")], 
  by.x = "template_name", by.y = "lab_label", all.x = TRUE)

# load catch data
cdse <- load_catch_data()
catch_onts <-cdse[taxon %like% 'Oncorhynchus tshawytscha']

#-------------------------------------------------------------------------------
# get median dna per bottle across the three replicate qPCR reactions
dna_by_bottle <- split(qpcr_data[,QuantBackCalc], qpcr_data[,template_name])

logadj <- function(x, ladj){log(x + ladj)}
log_adj <- 0.11 # was 0.00001

qpcr_data[ , log.dna.bottle := logadj(QuantBackCalc, ladj = log_adj), 
  by = template_name]

temp <- merge(x = qpcr_data, y = catch_onts[,.(event_id, value)], 
  by = 'event_id', all.x = TRUE)

with(temp[!is.na(value)], plot(value, log.dna.bottle))
log_dna_by_bottle <- lapply(dna_by_bottle, function(x) logadj(x, ladj = log_adj))

xtr <- axtr(unlist(dna_by_bottle), log_adj)

par(mar = c(4, 5, 1, 1))
stripchart(
  x = log_dna_by_bottle, 
  # method = "jitter", 
  pch = 21, cex = 0.5, col = grey(0.5), 
  xaxt = 'n', xlab = "DNA copies per reaction", 
  las = 1
  )
axis(1, at = xtr$tick, labels = xtr$lab)
stripchart(lapply(log_dna_by_bottle, median), lwd = 2, add = TRUE, 
  col = "blue", pch = 3)
stripchart(lapply(log_dna_by_bottle, mean), lwd = 6, add = TRUE, 
  col = "red", pch = "|")
legend('bottomright', bty = "n", 
  legend = c('median', 'mean'), pch = c(3, 124), col = c("blue", "red"))
dna_by_bottle_med <- sapply(dna_by_bottle, median)
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# calculate the median estimate for each event from the bottle estimates
bottle_to_event <- qpcr_data[
  match(names(dna_by_bottle_med), qpcr_data[,template_name]),
  event_id
]

dna_by_event_med <- sapply(split(dna_by_bottle_med, bottle_to_event), median)

# alternate version:
qpcr_data[,.(
  event_id, 
  medDNA = median(QuantBackCalc)), 
  by = template_name
][,
  .(medmedDNA = median(medDNA)),
  by = event_id
][
    order(event_id) 
]
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# get dna for each event
dna_by_event <- split(qpcr_data[,"QuantBackCalc"], qpcr_data[,"event_id"])
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# get sum of counts of chinook by sampling event
chinook_by_event <- catch_onts[,value]
names(chinook_by_event) <- catch_onts[,event_id]
chinook_by_event <- sapply( split(
  catch_chinook[,3:5], catch_chinook[,"event_id"]
), sum)
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# compute log for better plotting
chinook_by_event_log <- log(chinook_by_event + 1)
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
  fish     = chinook_by_event_log[bottle_to_event]
)[!is.na(bottle_to_event),] # remove rows of standards
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# arrange for plotting and modelling
dna  <- dna_by_event_med[events_in_both]
fish <- chinook_by_event_log[events_in_both]

plot_dat <- data.frame(
  event = names(unlist(dna)), 
  dna   = unlist(dna), 
  fish  = rep(fish, times = sapply(dna, length))
)
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# assess the fit of a linear model
model_linear <- lm(dna ~ fish, data = plot_dat)
model_linear_summary <- summary(model_linear)

x_pred <- seq(from = 0, to = max(plot_dat_bottle$fish), length.out = 10)

con95 <- predict(
    object   = model_linear,
    newdata  = data.frame(fish = x_pred),
    interval = "confidence",
    level    = 0.95
  )

#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# requires plot_dat, with columns named "dna" and "fish"
plot_name <- "DNA_by_seine_chinook"

EXPORT <- TRUE

if(!exists("legend_text")){legend_text <- list()}
legend_text[plot_name] <- {"
Concentration of Chinook Salmon DNA plotted against Chinook Salmon captured in beach seines at 10 sites in Skagit Bay.
At each site, 2 beach seines and 3-4 water samples were collected. 
The total number of Chinook across seine surveys is plotted here. 
DNA was extracted from each bottle and used as template in 3 independent qPCRs, 
the median of these is taken as the DNA concentration of each bottle (open gray circles);
the site concentration is taken as the median of these estimates (closed black circles).
A linear model demonstrates that the intercept cannot be distinguished from 0 (p = 0.596), 
while the number of fish (log(x+1)) was a significant predictor of median DNA concentration (p = 0.000762). 
While only one point appears at the origin (0,0), this represents two sites 
at which 0 Chinook were captured in seines and none of the water samples (8 total) contained Chinook DNA.
"}

if(EXPORT){
  pdf_file    <- file.path(fig_dir, paste(plot_name, ".pdf", sep = ""))
  legend_file <- file.path(fig_dir, paste(plot_name, "_legend.txt", sep = ""))
  writeLines(legend_text[[plot_name]], con = legend_file)
  pdf(file = pdf_file, width = 5, height = 5) #, width = 8, height = 3
}

par(mar = c(4,5,1,1))
plot(
  x = plot_dat_bottle$fish, 
  y = jitter(plot_dat_bottle$dna, factor = 0), 
  pch = 19, lwd = 2, col = hsv(1, 0, 0.5), 
  cex = 0.5, 
  axes = FALSE, 
  xlab = "Total Chinook in Beach Seines", 
  ylab = expression(paste("Concentration Chinook DNA (pg/", mu, "L)", sep = "")), 
  las = 1
  )
plot_model(con95, x_pred, line_color = "cornflowerblue")

# add medians
points(
  x = plot_dat$fish, 
  y = plot_dat$dna, 
  pch = 19, col = "black"
)

xaxis_ticks <- c(0, 5, 10, 25, 50, 100, 200)

axis(1, 
  at = log(xaxis_ticks + 1), 
  labels = xaxis_ticks
  )

axis(2, las = 1)

box()

if(EXPORT){
  dev.off()
}
#-------------------------------------------------------------------------------
