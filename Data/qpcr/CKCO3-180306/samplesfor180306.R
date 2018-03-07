samplesfor180306 <- function(samples_file = '~/Projects/Skagit_Salmon_eDNA/Documents/Labwork/2018-03-06-qpcr/samples_qpcr_180301.csv'){
  library(data.table)
  sample_names <- fread(samples_file, colClasses = 'character')[,lab_label]
  sample_names <- c(sample_names, "485") # add back in the missing sample
  sample_names <- sort(sample_names) # sort them

  # now replace the sample (trying to accomplish similar to pop in python)
  # with the last sample in the list, and drop the last one
  sample_names[sample_names == "485"] <- sample_names[length(sample_names)]

  sample_names <- sample_names[-length(sample_names)]
  
  return(sample_names)

}
