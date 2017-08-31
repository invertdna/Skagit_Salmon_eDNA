
library(googlesheets)
library(data.table)

cleaned_sheet_key <- "1d32mxfDkdnCf9ggN0BPdzyvvvGuj9obD_pry2iFlp_0"

cleaned <- data.table(gs_read(gs_key(cleaned_sheet_key)))
