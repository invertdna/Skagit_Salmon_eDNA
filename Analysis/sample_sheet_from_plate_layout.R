setwd("~/GoogleDrive/Data/qpcr_data/Jimmy_Batch_Export/CKCO3-170830/setup")
raw <- fread("plate_layout_abi.txt", colClasses = 'character')
colnames(raw) <- as.character(seq(from = 1, to = 22, length.out = 8))

plate_rows <- LETTERS[1:nrow(raw)]
plate_cols <- 1:24

raw[,plate_row := plate_rows]

raw.l <- melt(raw, 
  id.vars = 'plate_row', 
  variable.name = 'plate_col', 
  value.name = 'template_name'
)

# add plate column
raw.l[ , plate_col := as.numeric(as.character(plate_col))]

# add template_rep
raw.l[ , template_rep := 1]

# add concentration
concs <- rep(NA, nrow(raw.l))
concs[1:8] <- c(1, 1e-01, 1e-02, 1e-03, 1e-04, 1e-05, 1e-06, 0)
raw.l[ , template_conc := concs]

# add template type
types <- rep("sample", nrow(raw.l))
types[1:8] <- "standard"
raw.l[,template_type := types]


raw.list <- list(raw.l, copy(raw.l), copy(raw.l))
raw.list[[2]] <- raw.list[[2]][ , plate_col := plate_col + 1]
raw.list[[3]] <- raw.list[[3]][ , plate_col := plate_col + 2]

raw.list[[2]] <- raw.list[[2]][ , template_rep := template_rep + 1]
raw.list[[3]] <- raw.list[[3]][ , template_rep := template_rep + 2]

samplesheet <- rbindlist(raw.list)

# reorder
samplesheet <- samplesheet[order(plate_row, plate_col),]

# add plate well
samplesheet[ , plate_well := paste0(plate_row, plate_col)]

# add well ID (numeric)
samplesheet[ , well_id := 1:nrow(samplesheet)]

# need to add:
# template_type, template_conc, 
# fwrite(samplesheet, "sample_sheet.csv")
