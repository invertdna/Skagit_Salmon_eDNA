
library(googlesheets)

DNA_sheet_key <- "1rXBXtXW7Ov1Z_LMZo_2G8Wjo_XStsl9WerGKdnylBGw"

DNA <- data.table(gs_read(gs_key(DNA_sheet_key)))

done <- DNA[,gsub(pattern = "SKA-", "", source_label)]

to_extract <- to_pcr[ # from choose_samples.R
  !lab_label %in% done, 
  .(event_id, field_rep, filter_box, lab_label)
]
# fwrite(to_extract, "to_extract.csv")

# FILTERS <- read.table(
#   file = "samples_master - Sheet1.tsv", 
#   sep = "\t",
#   quote = "",
#   header = TRUE, 
#   stringsAsFactors = FALSE
# )

names(FILTERS)

the_cols <- c("date_collected", "site_name", "lab_label", "notes_lab")
the_rows <- !(FILTERS$lab_label %in% DNA$source_label) & 
  FILTERS$Project == "Skagit" & 
  !(is.na(FILTERS$Project == "Skagit"))

remaining_samples <- FILTERS[ the_rows, the_cols]

extractions_by_day <- sample(remaining_samples$lab_label)

names(extractions_by_day) <- rep(c("day1", "day2", "day3", "day4", "day5", "day6"), each = 16)[1:length(extractions_by_day)]

