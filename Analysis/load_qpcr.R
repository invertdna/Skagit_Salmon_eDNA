#-------------------------------------------------------------------------------
# load the data from several qpcr runs

# requires an object called "water"

# what was the concentration of the standard in nanograms per microliter
std1_conc <- 9.36

#-------------------------------------------------------------------------------
qpcr_data_file <- list()

qpcr_data_file[[1]] <- file.path(data_dir, 
  "qpcr/CKCO3-161209/results/results_table.txt")

qpcr_data_file[[2]] <- file.path(data_dir, 
  "qpcr/CKCO3-161214/results/results_table.txt")
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
setup_file <- list()

setup_file[[1]] <- file.path(data_dir, 
  "qpcr/CKCO3-161209/setup/sample_sheet.csv")

setup_file[[2]] <- file.path(data_dir, 
  "qpcr/CKCO3-161214/setup/sample_sheet.csv")
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
plate_id <- sapply(setup_file, function(x) strsplit(x, "/")[[1]][4])
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# load results files
qpcr_data_raw <- list()
for(i in 1:length(qpcr_data_file)){
  qpcr_data_raw[[i]] <- read.table(
    file = qpcr_data_file[[i]],
    skip = 10, 
    sep  = "\t", 
    stringsAsFactors = FALSE, 
    header = TRUE
  )
}
names(qpcr_data_raw) <- plate_id
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# load setup files
setup_raw <- list()
for(i in 1:length(setup_file)){
  setup_raw[[i]] <- read.csv(
    file = setup_file[[i]], 
    stringsAsFactors = FALSE
  )
}

setup <- list()
for(i in 1:length(setup_file)){
  setup[[i]] <- setup_raw[[i]][!is.na(setup_raw[[i]][,"template_name"]), ]
}
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# exclude wells from data that weren't used in setup
for(i in 1:length(qpcr_data_raw)){
  qpcr_data_raw[[i]] <- qpcr_data_raw[[i]][ 
    qpcr_data_raw[[i]][,"Position"] %in% setup[[i]][,"plate_well"],
  ]
}
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# add sample names to qpcr results
for(i in 1:length(qpcr_data_raw)){
qpcr_data_raw[[i]]$template_name <- setup[[i]][
  match(qpcr_data_raw[[i]][,"Position"], setup[[i]][,"plate_well"]), 
  "template_name"
  ]
}
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# identify irrelevant columns for exclusion
cols_to_keep <- c(
  "Position", 
  "Task", 
  "template_name", 
  "Ct", 
  "Quantity"
)
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# bind data from multiple runs into a single data frame
qpcr_data <- data.frame()
for(i in 1:length(qpcr_data_raw)){
  qpcr_data <- rbind.data.frame(qpcr_data, 
    data.frame(
      plate_id = rep(plate_id[[i]], nrow(qpcr_data_raw[[i]])), 
      qpcr_data_raw[[i]][,cols_to_keep]
    )
  )
}
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Exclude FIELD samples at dilution 1:100
qpcr_data <- qpcr_data[
  !(grepl("_0.01", qpcr_data[,"template_name"]) &
     qpcr_data[,"Task"] == "Unknown"),
  ]
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# rename field samples ending in 0.1
to_rename <- which(grepl("_0.1", qpcr_data[,"template_name"]) &
     qpcr_data[,"Task"] == "Unknown")

new_names <- gsub("_0.1", "", qpcr_data[to_rename,"template_name"])
qpcr_data[to_rename, "template_name"] <- new_names
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# remove project prefix ('SKA' | 'SKA-')
qpcr_data[,"template_name"] <- gsub("SKA|SKA-", "", qpcr_data[,"template_name"])
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# add event_id column to qPCR data
qpcr_data$event_id <- water[["event_id"]][match(
  qpcr_data[["template_name"]],
  water[["lab_label"]]
  )
]
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# add inferred concentration from standard
qpcr_data$QuantBackCalc <- qpcr_data[,"Quantity"] * std1_conc
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# convert quantities to picograms per microliter (makes plotting better)
qpcr_data[,"QuantBackCalc"] <- qpcr_data[,"QuantBackCalc"] * 1000
#-------------------------------------------------------------------------------

