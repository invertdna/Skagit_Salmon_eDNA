DNA <- read.table(
  file = "DNA_extractions - DNA_extractions.csv.tsv",
  sep = "\t",
  quote = "",
  header = TRUE, 
  stringsAsFactors = FALSE
)

FILTERS <- read.table(
  file = "samples_master - Sheet1.tsv", 
  sep = "\t",
  quote = "",
  header = TRUE, 
  stringsAsFactors = FALSE
)

names(FILTERS)

the_cols <- c("date_collected", "site_name", "lab_label")
the_rows <- !(FILTERS$lab_label %in% DNA$source_label) & 
  FILTERS$Project == "Skagit" & 
  !(is.na(FILTERS$Project == "Skagit"))

remaining_samples <- FILTERS[ the_rows, the_cols]
remaining_samples
dim(remaining_samples)
extractions_by_day <- sample(remaining_samples$lab_label)

days <- c("2016-10-12","2016-10-13","2016-10-17","2016-10-18","2016-10-19")
# names(extractions_by_day) <- rep(c("day1", "day2", "day3", "day4", "day5", "day6"), each = 16)[1:length(extractions_by_day)]

date_extract <- rep(days, each = 20)[1:nrow(remaining_samples)]

remaining_samples

extractions_df <- data.frame(
  date_extract,
  remaining_samples[sample(1:nrow(remaining_samples)),]
)
extractions_df[with(extractions_df, order(date_extract, lab_label)),]

edit(remaining_samples)


split(remaining_samples$lab_label, with(remaining_samples, paste(date_collected, site_name)))
sample(1:4, size = 10, replace = TRUE)
