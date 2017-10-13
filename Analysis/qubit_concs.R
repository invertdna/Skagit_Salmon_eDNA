
the_dir <- '../Data/qubit'

paths_rel <- list.files()
paths_full <- file.path(the_dir, paths_rel)

dna_types <- c(
  "genomicDNA", 
  "genomicDNA", 
  "PCR1", 
  "PCR2", 
  "PCR1_fullstrength", 
  "PCR2_clean", 
  "PCR1_clean", 
  "PCR1_dirty", 
)

for(i in paths_full){}