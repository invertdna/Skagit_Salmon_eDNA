library(data.table)

qubit_file <- "/Users/jimmy.odonnell/Projects/Skagit_Salmon_eDNA/Data/qubit/QubitData_2017-07-21_01-35-59.csv"

qubit <- fread(qubit_file)

names(qubit) <- gsub(" ", ".", names(qubit))


sample.env <- substr(qubit$Sample_Name, 1, 7)

qubit$sample.env <- sample.env


pldat <- split(qubit$Original.sample.conc., qubit[, "sample.env"])

stripchart(pldat, 
  method = "jitter", 
  xlim = c(0, max(unlist(pldat))), 
  las = 1
)

abline(h = 1:length(pldat), col = grey(0.5, 0.5))

range(unlist(pldat))

nM_per_lib <- function(conc, size){
	# calculate nM of library given conc (ng/uL) and size (bp)
	nM <- (conc/ (size*660))* 1000000
	return(nM)
}

nM_per_lib(3, 443)
nM_per_lib(mean(unlist(pldat)), 443)
nM_per_lib(1, 443)