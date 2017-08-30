
library(googlesheets)
library(data.table)

DNA_sheet_key <- "1rXBXtXW7Ov1Z_LMZo_2G8Wjo_XStsl9WerGKdnylBGw"

DNA <- data.table(gs_read(gs_key(DNA_sheet_key)))
