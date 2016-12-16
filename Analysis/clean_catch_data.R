# clean catch data

#-------------------------------------------------------------------------------
# Where is the file?
file_path <- file.path(data_dir, "catch_data", "2016-05.csv")

# Which columns actually contain counts of organisms?
count_colnums <- 15:188
#-------------------------------------------------------------------------------

catch_data_raw <- read.csv(file_path, stringsAsFactors = FALSE)
count_colnames <- colnames(catch_data_raw)[count_colnums]
catch_data <- catch_data_raw


# correct the dates to be POSIX compliant
correct_date <- function(x){
	x2    <- rev(strsplit(x, "-")[[1]])
	x2[1] <- paste0("20", x2[1])
	x2[2] <- sprintf("%02s", grep(x2[2], month.name))
	x2[3] <- sprintf("%02s", x2[3])
	x2    <- paste(x2, collapse = "-")
	return(x2)
}
catch_data[,"Date"] <- sapply(catch_data[,"Date"], correct_date)

DateTime <- as.POSIXct(paste(catch_data[,"Date"], catch_data[,"Time"]))


# abbreviate site names
file_path  <- file.path(data_dir, "site_codes.txt")
site_trans <- read.table(file_path, stringsAsFactors = FALSE)
site_abbr  <- site_trans[match(catch_data$Site, site_trans[,2]),1]

short_time <- gsub(":00$", "", DateTime)
short_time <- gsub("^20", "", short_time)
short_time <- gsub(":", "", short_time)
short_time <- gsub("-", "", short_time)
short_time <- gsub(" ", "-", short_time)

# create unique sample identifiers
sample_id <- paste(site_abbr, short_time, sep = "-")

event_id  <- substr(sample_id, 1, 13)

#-------------------------------------------------------------------------------
# isolate metadata and data
catch_metadata <- data.frame(sample_id, event_id, catch_data[,-count_colnums])

# get names of columns where organism was observed at least once
org_absent  <- names(which(colSums(catch_data[,count_colnames]) < 1 ))
org_present <- names(which(colSums(catch_data[,count_colnames]) > 0 ))


#-------------------------------------------------------------------------------
# remove organisms with no counts
catch_data <- data.frame(sample_id, event_id, catch_data[,org_present])

#-------------------------------------------------------------------------------
# isolate chinook
catch_chinook <- catch_data[,c(1, 2, grep("^CK", colnames(catch_data)))]

