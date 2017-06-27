# after first loading, it will open a browser and ask you to authorize
library(googlesheets)
library(data.table)
# library(lubridate)

EXPORT <- FALSE

# list all available sheets
my_sheets <- gs_ls()

GS <- gs_key("1IzJG3jaZCNXu6GNtx0ltsyJn0D8bprWs6NcYXCTGg_A")

DT <- data.table(gs_read(GS, ws = 1))

SITEDATES <- split(DT$Date, DT$SiteName)

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