
library(googlesheets)
library(data.table)

DNA_sheet_key <- "1tWeJMDBqVydnRPsW_ql65Xd0PDLYWf8mQIP7T0fNmvc"
#"1rXBXtXW7Ov1Z_LMZo_2G8Wjo_XStsl9WerGKdnylBGw"

DNA <- data.table(gs_read(gs_key(DNA_sheet_key)))
