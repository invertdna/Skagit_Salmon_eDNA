# load qubit file

load_qubit <- function(filepath, dna_type)
{
  library(data.table)
  qubit <- fread(filepath)
  qubit[,dna_type := dna_type]
  return(qubit)
}
