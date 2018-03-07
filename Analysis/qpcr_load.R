#-------------------------------------------------------------------------------
# Load qPCRs into a list
#-------------------------------------------------------------------------------

res <- list()

#-------------------------------------------------------------------------------
# 1
res[[1]] <- load_qpcr(
  qpcr_data_file = "../Data/qpcr/CKCO3-161209/results/results_table.txt", 
  sample_sheet_file = "../Data/qpcr/CKCO3-161209/setup/sample_sheet.csv", 
  std_conc = 9.36)
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# 2
cols_to_remove <- c('no_lab_error', 'note')
res[[2]] <- load_qpcr(
  qpcr_data_file = "../Data/qpcr/CKCO3-161214/results/results_table.txt", 
  sample_sheet_file = "../Data/qpcr/CKCO3-161214/setup/sample_sheet.csv", 
  std_conc = 9.36
)[ 
  # exclude samples with lab error:
  no_lab_error == TRUE , ][, 
  (cols_to_remove) := NULL]
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# 3
res[[3]] <- load_qpcr(
  qpcr_data_file = '../Data/qpcr/CKCO3-170712/results/results_table.txt', 
  sample_sheet_file = '../Data/qpcr/CKCO3-170712/setup/sample_sheet.csv', 
  std_conc = 1)
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# 4
res[[4]] <- load_qpcr(
  qpcr_data_file = "../Data/qpcr/CKCO3-170830/results/CKCO3-170830_result.txt", 
  sample_sheet_file = "../Data/qpcr/CKCO3-170830/setup/sample_sheet.csv", 
  std_conc = 1)[,well_id := NULL]
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# 5: note the std quantity was 4.78 and was entered into the software on the qpcr machine.
res[[5]] <- load_qpcr(
  qpcr_data_file = "../Data/qpcr/CKCO3-180102/results/CKCO3-180102_result.txt",
  sample_sheet_file = "../Data/qpcr/CKCO3-180102/setup/sample_sheet.csv", 
  std_conc = 1)[,Quantity := Quantity/4.78]
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# 6: note the std quantity was 1.05 and was entered into the software on the qpcr machine.
res[[6]] <- load_qpcr(
  qpcr_data_file = "../Data/qpcr/CKCO3-180302/results/CKCO3-180302_result.txt",
  sample_sheet_file = "../Data/qpcr/CKCO3-180302/setup/sample_sheet.csv", 
  std_conc = 1)[ , c('Quantity') := list(Quantity/1.05)][]
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# 7: note the std quantity was 1.05 and was entered into the software on the qpcr machine.
res[[7]] <- load_qpcr(
  qpcr_data_file = "../Data/qpcr/CKCO3-180306/results/CKCO3-180306_result.txt",
  sample_sheet_file = "../Data/qpcr/CKCO3-180306/setup/samples.csv", 
  std_conc = 1)[ , c('Quantity') := list(Quantity/1.05)][]
#-------------------------------------------------------------------------------
