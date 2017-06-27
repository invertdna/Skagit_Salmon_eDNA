
# requires environmental samples data
# (see load_water_samples.R or 0_load_project.R)

library(data.table)
library(lubridate) # date()

EXPORT <- FALSE

SITEDATES <- split(water$date, water$site_name)

# exclude randoms and aquariums
SITEDATES <- SITEDATES[!grepl(pattern = "Random|Aquarium", names(SITEDATES))]


#-------------------------------------------------------------------------------
# PLOTTING
plot_name   <- "site_visits"

if(!exists("legend_text")){legend_text <- list()}

legend_text[plot_name] <- {
"Dates at which samples were collected at each site."
}

if(EXPORT){
  pdf_file    <- file.path(fig_dir, paste(plot_name, ".pdf", sep = ""))
  legend_file <- file.path(fig_dir, paste(plot_name, "_legend.txt", sep = ""))
  writeLines(legend_text[[plot_name]], con = legend_file)
  pdf(file = pdf_file, width = 9, height = 5)
}

par(mar = c(4,12,1,1))
stripchart(SITEDATES, 
  method = "jitter", pch = 1, cex = 0.8,
  xaxt = "n", 
  las = 1
)
abline(h = 1:length(SITEDATES), lty = 2, col = grey(0.5, alpha = 0.2))
tickdates <- c("2016-07-01", "2017-01-01", "2017-02-01", "2017-03-01", 
  "2017-04-01", "2017-05-01", "2017-06-01")
axis(1, at = as.numeric(date(tickdates)), labels = format(date(tickdates), "%b"))

if(EXPORT){
	dev.off()
}