dna_file <- "~/Downloads/DNA_extractions - sheet1.csv"

dna <- read.csv(dna_file, stringsAsFactors = FALSE)

to_extract <- vector()

ika_upper <- paste0("SKA-", sprintf("%03d", 57:62))

ika_lower <- paste0("SKA-", sprintf("%03d", c(63, 64, 65, 67, 68, 69)))

site <- ika_upper


print(dna[which(dna[,"source_label"] %in% site),])
dna[which(dna[,"source_label"] %in% site),"source_label"]

to_extract <- c(to_extract, dna[which(dna[,"source_label"] %in% site),"source_label"])

dna[order(dna$extraction_label),]
dna

all <- paste0("SKA-", sprintf("%03d", 1:137))
match(dna$extraction_label, all)
data.frame(
  all,
  done = dna$extraction_label[match(all, dna$extraction_label)]
)

extracted <- dna$extraction_label[grep("SKA", dna$extraction_label)]

extracted_samples <- water[water[,"lab_label"] %in% extracted,c("date_collected", "time", "site_name", "lab_label")]
write.csv(extracted_samples, file = "extracted.csv", quote = FALSE, row.names = FALSE)

