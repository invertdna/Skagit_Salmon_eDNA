# load qubit file

load_qubit <- function(filepath, dna_type = NULL)
{
  library(data.table)
  qubit <- fread(filepath)
  if(!is.null(dna_type)){ # could use missing()
  	qubit[,dna_type := dna_type]
  }
  return(qubit)
}
