################################################################################
load_cleaned <- function(sheet_id = 
  "1d32mxfDkdnCf9ggN0BPdzyvvvGuj9obD_pry2iFlp_0"){
  library(googlesheets)
  library(data.table)
  cleaned <- data.table(gs_read(gs_key(sheet_id)))
  return(cleaned)
}
