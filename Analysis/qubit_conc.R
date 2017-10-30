library(data.table)

qubit_file <- "../Data/qubit/QubitData_2017-07-21_01-35-59.csv"

qubit <- load_qubit(qubit_file)

qubit[, sample.env := substr(qubit$Sample.Name, 1, 7)]

pldat <- split(qubit$Original.sample.conc., qubit$sample.env)

stripchart(pldat, 
  method = "jitter", 
  xlim = c(0, max(unlist(pldat))), 
  las = 1
)
abline(h = 1:length(pldat), col = grey(0.5, 0.5))

(RANGE <- range(unlist(pldat)))
text(x = RANGE, y = length(pldat)+1.5, labels = RANGE, col = "red", xpd = TRUE)

nM_per_lib <- function(conc, size){
	# calculate nM of library given conc (ng/uL) and size (bp)
	nM <- (conc/ (size*660))* 1000000
	return(nM)
}

nM_per_lib(3, 443)
nM_per_lib(mean(unlist(pldat)), 443)
nM_per_lib(1, 443)
