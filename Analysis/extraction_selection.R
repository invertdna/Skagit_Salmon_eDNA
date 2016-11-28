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

the_cols <- c("date_collected", "site_name", "lab_label", "notes_lab")
the_rows <- !(FILTERS$lab_label %in% DNA$source_label) & 
  FILTERS$Project == "Skagit" & 
  !(is.na(FILTERS$Project == "Skagit"))

remaining_samples <- FILTERS[ the_rows, the_cols]

extractions_by_day <- sample(remaining_samples$lab_label)

names(extractions_by_day) <- rep(c("day1", "day2", "day3", "day4", "day5", "day6"), each = 16)[1:length(extractions_by_day)]

