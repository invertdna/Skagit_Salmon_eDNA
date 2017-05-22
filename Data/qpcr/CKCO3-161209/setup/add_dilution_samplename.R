
#-------------------------------------------------------------------------------
# sample_names
samples_orig <- read.table("sites_161208.txt", stringsAsFactors = FALSE)[,1]
samples_ordered <- samples_orig[c(1:4, 1:4, 5:8, 5:8, 9:12, 9:12)]

sample_names <- paste0(samples_ordered, rep(c("_0.1", "_0.01"), each = 4))

write.table(sample_names, file = "samples.txt", quote = FALSE,
  row.names = FALSE, col.names = FALSE)

