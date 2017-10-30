source("./functions/load_qubit.R")

the_dir <- '../Data/qubit'

paths <- list.files(path = "../Data/qubit", full.names = TRUE)

dna_types <- c(
  "genomicDNA", 
  "genomicDNA", 
  "PCR1", 
  "PCR2", 
  "PCR1_fullstrength", 
  "PCR2_clean", 
  "PCR1_clean", 
  "PCR1_dirty" 
)

qubit_dat <- list()
for(i in 1:length(paths)){
  qubit_dat[[i]] <- load_qubit(paths[i], dna_types[i])
  # colnames(qubit_dat[[i]]) <- make.names(colnames(qubit_dat[[i]]), unique = TRUE)
}

# remove extra column
qubit_dat[[1]][,replicate:=NULL]

neworder <- colnames(qubit_dat[[2]])
# neworder <- make.names(neworder, unique = TRUE)

for(i in 1:length(paths)){
  print(identical(sort(neworder), sort(colnames(qubit_dat[[i]]))))
}

lapply(qubit_dat, setcolorder, neworder)

qubit_dat <- rbindlist(qubit_dat)

plot_dat <- with(qubit_dat, split(Original.sample.conc., dna_type))
par(mar = c(5,4,0,0))
boxplot(plot_dat, axes = FALSE, outline = TRUE)
axis(2, las = 1); title(ylab = "DNA concentration (ng/uL)")
axis(1, at = 1:length(plot_dat), labels = FALSE, pos = 0)
abline(h = 0)
text(x = 1:length(plot_dat), y = -1, labels = names(plot_dat), srt = 45, adj = c(1.1, 1.1), xpd = TRUE)
