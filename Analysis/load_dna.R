################################################################################
load_dna <- function(sheet_id = "1tWeJMDBqVydnRPsW_ql65Xd0PDLYWf8mQIP7T0fNmvc"){
  library(googlesheets)
  library(data.table)
  #"1rXBXtXW7Ov1Z_LMZo_2G8Wjo_XStsl9WerGKdnylBGw"
  DNA <- data.table(gs_read(gs_key(sheet_id)))
  return(DNA)
}
