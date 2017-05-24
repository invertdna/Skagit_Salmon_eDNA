library("data.table")


DF <- read.csv("PCR_reagents.csv")

head(DF)

DF[DF$reagent == "MgCl",]


reagent == ""

DT <- data.table(DF)

head(DT)

DT[ reagent == "MgCl", ]

split(DF, DF$reagent)

with(DF, split(DF, reagent))

vol_final <- 10

DF[ DF$rxn_name == "eDNA-CYAG-Jimmy", ]

DT[ rxn_name == "eDNA-CYAG-Jimmy", sum(vol_10uL) ]

################################################################################
vol_for_rxn <- function(vol_rxn, reagent_name, conc_stock, conc_rxn){
# calculate the volume needed of reagents for PCR reaction
# input: vectors of names and concentrations (stock and reaction) of reagents
# output: named vector of volumes needed for input
# note: concentration UNITS of stock and reaction must be the same
  if(
    length(reagent_name) != length(conc_stock) | 
    length(conc_stock) != length(conc_rxn)
  ){stop("arguments reagent_name, conc_stock, and conc_desired must be same length")}
  vol_required <- vector()
  for(i in 1:length(reagent_name)){
  	vol_required[i] <- conc_rxn[i] * vol_rxn / conc_stock[i]
  }
  names(vol_required) <- reagent_name
  
  return(vol_required)
}

myDT <- DT[rxn_name == "eDNA-CYAG-Jimmy", ]

myVol <- vol_for_rxn(10, as.character(myDT$reagent), myDT$conc_init, myDT$conc_final)

sum(myVol, na.rm = TRUE)

myDT[,sum(vol_10uL)]

myDT[,sum(vol_25uL)]

# report the volume needed 
soup <- function(N, names, vols, excess = 1.1){
  vols <- vols * excess * N
  names(vols) <- names
  return(vols)
}

# should I make enough for an extra rxn per primer set, or add a percentage?
soup(32, myDT[,reagent], myDT[,vol_10uL], 1) /
soup(28, myDT[,reagent], myDT[,vol_10uL], 1.1)
# make enough for an extra rxn per primer


per_8rxn <- soup(8, myDT[,reagent], myDT[,vol_10uL], 1)
per_32rxn <- soup(32, myDT[,reagent], myDT[,vol_10uL], 1)
myDT[ , .(reagent, vol_10uL)]

for_labwork <- data.table(myDT[ , .(reagent, vol_10uL)], per_8rxn, per_32rxn)
fwrite(for_labwork, file = "pcr_prep.txt")
