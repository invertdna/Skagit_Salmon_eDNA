#' Load qPCR output files.
#' 
#' @param std_conc Numeric. Concentration of 1:1 standard in ng per uL.
#' @param qpcr_data_file String. Path to qPCR output file.
#' @param sample_sheet_file String. Path to sample sheet file, or NULL.
#' @param drop_cols Logical. Drop columns besides "Position", "Task", "Ct", "Quantity"
#' @param drop_100 Logical. Drop samples with template diluted 1:100.
#' @param quant1000 Logical. Convert quantities to pg/uL for better plotting
#' 
#' @examples  
#'   load_qpcr(
#'     std_conc = 9.36, 
#'     qpcr_data_file = "../Data/qpcr/CKCO3-161209/results/results_table.txt", 
#'     sample_sheet_file = "../Data/qpcr/CKCO3-161209/setup/sample_sheet.csv"
#'     )
#' 
#' @export
load_qpcr <- function(
  std_conc, qpcr_data_file, sample_sheet_file = NULL, 
  drop_cols = TRUE, drop_100 = TRUE, quant1000 = TRUE)
{
  library(data.table)
  
  temp <- strsplit(qpcr_data_file, "/")[[1]]
  plate_id <- temp[length(temp)-2]
  
  qpcr_results <- fread(qpcr_data_file)

  if(drop_cols){
    # identify irrelevant columns for exclusion
    cols_to_keep <- c("Position", "Task", "Ct", "Quantity")
    qpcr_results <- qpcr_results[,cols_to_keep, with = FALSE]
  }
  
  qpcr_results[Ct == "Undetermined", Ct := NA ]
  qpcr_results[, Ct := as.numeric(Ct) ]
  
  # change 'NTC' to 'Standard'
  qpcr_results[Task == "NTC", Task := "Standard" ]
  
  qpcr_results[, plate_id := plate_id ]
  
  if(!is.null(sample_sheet_file)){
    setup <- fread(sample_sheet_file)
    setup <- setup[!is.na(template_name), ]
    
    qpcr_results <- qpcr_results[Position %in% setup$plate_well, ]
    
    full <- merge(x = qpcr_results, 
                  y = setup[,-c("template_type", "plate_row", "plate_col")], 
                  by.x = "Position", by.y = "plate_well"
    )
    # Exclude FIELD samples at dilution 1:100
    if(drop_100){
      full <- full[ !(template_name %like% "_0.01" & Task == "Unknown"), ]
    }

    # rename field samples ending in 0.1
    full[ Task == "Unknown", template_name := gsub("_0.1", "", template_name)]
    
    # remove project prefix ('SKA' | 'SKA-')
    full[ , template_name := gsub("SKA|SKA-", "", template_name)]
  }else{
    full <- qpcr_results
  }
    
  # add inferred concentration from standard
  full[, QuantBackCalc := Quantity * std_conc]
  
  # convert quantities to picograms per microliter (makes plotting better)
  if(quant1000){
    full[, QuantBackCalc := QuantBackCalc * 1000]
  }
  
  return(full)
  
}
