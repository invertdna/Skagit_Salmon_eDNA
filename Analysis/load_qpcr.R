load_qpcr <- function(
  std_conc, # concentration of full-strength standard
  qpcr_data_file, sample_sheet_file, 
  drop_cols = TRUE, drop_100 = TRUE, quant1000 = TRUE)
{
  library(data.table)
  
  plate_id <- strsplit(qpcr_data_file, "/")[[1]][4]
  
  qpcr_results <- fread(qpcr_data_file)

  if(drop_cols){
    # identify irrelevant columns for exclusion
    cols_to_keep <- c("Position", "Task", "Ct", "Quantity")
    qpcr_results <- qpcr_results[,cols_to_keep, with = FALSE]
  }

  qpcr_results[, plate_id := plate_id ]
  
  setup <- fread(sample_sheet_file)
  setup <- setup[!is.na(template_name), ]
  
  qpcr_results <- qpcr_results[Position %in% setup$plate_well, ]
  
  full <- merge(x = qpcr_results, 
                y = setup[,-c("template_type", "plate_row", "plate_col")], 
                by.x = "Position", by.y = "plate_well")
  
  # Exclude FIELD samples at dilution 1:100
  if(drop_100){
    full <- full[ !(template_name %like% "_0.01" & Task == "Unknown"), ]
  }

  # rename field samples ending in 0.1
  full[ Task == "Unknown", template_name := gsub("_0.1", "", template_name)]
  
  # remove project prefix ('SKA' | 'SKA-')
  full[ , template_name := gsub("SKA|SKA-", "", template_name)]
  
  # add inferred concentration from standard
  full[, QuantBackCalc := Quantity * std1_conc]
  
  # convert quantities to picograms per microliter (makes plotting better)
  if(quant1000){
    full[, QuantBackCalc := QuantBackCalc * 1000]
  }
  
  return(full)
  
}
