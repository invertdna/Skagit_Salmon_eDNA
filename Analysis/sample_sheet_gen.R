################################################################################
# setwd("~/Projects/Skagit_Salmon_eDNA/Data/qpcr/CKCO3-170712/setup")

samplefile <- "samples.txt" # "2017-07-12_samples.txt"
samplenames <- read.table(samplefile, colClasses = "character")[,1]
plated <- plate_it(samplenames, plate_size = 96, reps = 4)
EXPORT <- FALSE
if(EXPORT){
  write.csv(plated[[1]], file = "sample_sheet.csv", row.names = FALSE, quote = FALSE)
  write.csv(plated[[2]], file = "plate_layout.csv")
}


setwd("~/GoogleDrive/Data/qpcr_data/Jimmy_Batch_Export/CKCO3-170830")
tmp <- fread("results/CKCO3-170830_result.txt")

plot(tmp[,Quantity], log = 'y')
plot(log1p(tmp[,Quantity]), log = 'y')
abline(h = 0)
samplefile <- "setup/samples.txt" # "2017-07-12_samples.txt"
samplenames <- read.table(samplefile, colClasses = "character")[,1]
plated <- plate_it(samplenames, plate_size = 96, reps = 4)
EXPORT <- FALSE
if(EXPORT){
  write.csv(plated[[1]], file = "sample_sheet.csv", row.names = FALSE, quote = FALSE)
  write.csv(plated[[2]], file = "plate_layout.csv")
}
