#' Load data from SRSC fish surveys.
#' 
#' @param counts.file File path. CSV file 
#' @param site.dt Data table. Site data.
#' @param count.colnums Which columns actually contain counts of organisms?
#' @param org.names.file String. Path to 2 column CSV file of translations 
#'   from names used in count columns to scientific names.
#' @param collapse.by String. Collapse multiple observations of same taxa 
#'   (e.g. juvenile and adult of one taxon) by "event", "sample", or "none"
#' @param metadata Logical. Return metadata only, instead of counts?
#' 
#' @return A data table (long/tall format) of three or four columns.
#' 
#' @examples 
#' cdse <- load_catch_data()
#' catch_metadata <- load_catch_data(metadata = TRUE)
#' 
#' @export
load_catch_data <- function(
  counts.file = file.path(data_dir, "catch_data", "2016-05.csv"), 
  site.dt = load_sites("../Data/sites.csv", gps.req = FALSE), 
  count.colnums = 15:188, 
  org.names.file = file.path(data_dir, "catch_data", "organism_names.csv"), 
  collapse.by = "event", 
  metadata = FALSE)
{
  library(data.table)
  library(lubridate)
  
  # requires site data is loaded
  # sites <- site.dt #
  
  #-------------------------------------------------------------------------------
  catch_data <- read.csv(counts.file, stringsAsFactors = FALSE)
  count_colnames <- colnames(catch_data)[count.colnums]
  
  # correct the dates to be POSIX compliant
  catch_data[,"Date"] <- dmy(catch_data[,"Date"])
  DateTime <- lubridate::ymd_hm(
    paste(catch_data[,"Date"], catch_data[,"Time"]), tz = "America/Los_Angeles")
  
  # abbreviate site names
  site_abbr  <- site.dt$Abbr[match(catch_data$Site, site.dt$NameSRSC)]
  
  # create unique sample identifiers
  # gsub removes "00" from the end, "20" from the start, and drops : and -
  short_time <- gsub(" ", "-", gsub(":00$|^20|:|-", "", DateTime))
  sample_id <- paste(site_abbr, short_time, sep = "-")
  event_id  <- substr(sample_id, 1, 13)
  
  #-------------------------------------------------------------------------------
  # isolate metadata and data
  catch_metadata <- data.frame(sample_id, event_id, catch_data[,-count.colnums])
  
  # get names of columns where organism was observed at least once
  org_absent  <- names(which(colSums(catch_data[,count_colnames]) < 1 ))
  org_present <- names(which(colSums(catch_data[,count_colnames]) > 0 ))
  
  #-------------------------------------------------------------------------------
  # remove organisms with no counts
  catch_data <- data.frame(sample_id, event_id, catch_data[,org_present])
  
  # make long form, convert to data.table
  catch_data.l <- melt(data.table(catch_data), 
                       id.vars = c('sample_id', 'event_id'), 
                       variable.name = "taxon")
  
  #-------------------------------------------------------------------------------
  # use scientific names
  org_names <- read.csv(org.names.file, header = FALSE, stringsAsFactors = FALSE, 
                        col.names = c("common", "scientific"))
  match_v <- match(levels(catch_data.l$taxon), org_names[,"common"])
  levels(catch_data.l$taxon) <- org_names[match_v,"scientific"]
  
  # TODO make separate columns for life history?
  
  #-------------------------------------------------------------------------------
  # combine duplicate observations of the same taxa...
  if(collapse.by == "sample"){
    # ...by SAMPLE (i.e. seine rep)...
    indexVars <- c("sample_id", "event_id", "taxon")
    catch_data.l <- catch_data.l[ , list(value = sum(value)), by = c(indexVars)]
  } else if(collapse.by == "none"){
  } else {
    # ...or by EVENT (i.e. site visit). THIS IS THE RIGHT SET TO USE
    catch_data.l <- catch_data.l[ , list(value = sum(value)), by = c("event_id", "taxon")]
  }
  if(metadata){
    return(catch_metadata)
  } else {
    return(catch_data.l)
  }
}

#-------------------------------------------------------------------------------
# isolate chinook
# catch_chinook <- cdse[taxon == "Oncorhynchus tshawytscha"]
# cdse[taxon %like% "Cymatogaster",]
# plot(cdse[taxon %like% "Cymatogaster", value])
# summer16_events <- levels(cdse$event_id)
# water[event_id %in% summer16_events,.(event_id, lab_label)]
