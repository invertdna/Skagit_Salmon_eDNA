# load qubit file

load_qubit <- function(filepath, dna_type = NULL)
{
  library(data.table)
  qubit <- fread(filepath)
  if(!is.null(dna_type)){ # could use missing()
  	qubit[,dna_type := dna_type]
  }
  colnames(qubit) <- make.names(colnames(qubit), unique = TRUE)
  qubit[ Original.sample.conc. == "Out of range", Original.sample.conc. := "0"]
  qubit[ Qubit..tube.conc. == "Out of range", Qubit..tube.conc. := "0"]
  qubit[ , Original.sample.conc. := as.numeric(Original.sample.conc.)]
  qubit[ , Qubit..tube.conc. := as.numeric(Qubit..tube.conc.)]
  return(qubit)
}
