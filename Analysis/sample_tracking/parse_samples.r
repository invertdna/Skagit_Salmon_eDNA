### Tracking status of samples
library(dplyr)
data.dir <- "/Users/ole.shelton/GitHub/Skagit_Salmon_eDNA/Data"

setwd(paste0(data.dir,"/sample_info"))

env_samp    <- read.csv("environmental_samples.csv")
env_samp$lab_label <- as.character(env_samp$lab_label)

dna_extract <- read.csv("DNA_extractions.csv")
dna_extract$extraction_label <- as.character(dna_extract$extraction_label)

dna_clean   <- read.csv("DNA_cleanup.csv")


extract <- left_join(env_samp,select(dna_extract,extraction_label,date_extracted),by=c("lab_label"="extraction_label"))

extract$processed[is.na(extract$date_extracted)==F] <- 1
extract$processed[is.na(extract$date_extracted)==T] <- 0



summary.extract <- extract %>% select(lab_label,date,site_name,processed)
summary.extract$lab_label <- paste0("x.",summary.extract$lab_label)

setwd("/Users/ole.shelton/Desktop")
write.csv(summary.extract,file="eDNA-Skagit-extraction-samples.csv")

ext.summ <-  extract %>% group_by(site_name,date) %>% summarize(Sum = sum(processed))

### Doesn't quite work yetextract_and_clean <- left_join(extract,select(dna_clean))

