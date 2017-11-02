#!/usr/bin/env Rscript

# Piper generously provided some DNA from coho and chinook salmon to test our qPCR assay
# this script reformats from plate layour to table layout

library(reshape2) # melt

plate_layout <- read.table(file.path("../Data", "plated_dna.txt"), header = TRUE, row.names = NULL)

DNA <- melt(plate_layout, id.vars = "row.names")

names(DNA) <- c("plate_row", "plate_col", "dna_id")

DNA$plate_col <- substr(as.character(DNA$plate_col), 2, 2)

# these come from the sheet Piper printed and gave to me
species       <- vector()
species[1:5]  <- "Oncorhynchus kisutch"
species[6]    <- NA
species[7:24] <- "Oncorhynchus tshawytscha"

# these come from the sheet Piper printed and gave to me
origin <- vector()
origin[1:5]   <- "California"
origin[6]     <- NA
origin[7:16]  <- "Oregon Coast"
origin[17:24] <- "California Coast"

DF <- data.frame(
  DNA,
  species,
  origin
)

EXPORT <- FALSE
if(EXPORT){
  write.csv(DF, file = file.path("../Data", "dna_piper.csv"), row.names = FALSE)
}
