#' Format strings so they can be formatted by lubridate eyerollemoji
#'
#' This function makes strings of numbers (e.g. "0759", "080130") into strings
#' that can be recognized and converted by lubridate functions like ms and hms
#' 
#' @param VEC A character vector containing strings of length 4 or 6, or NAs
#' 
#' @return A character vector identical to input but where every element has 8 
#' characters, with colons at position 3 and 5. NA is returned as NA.
#' 
#' @examples 
#' maketime(NA)
#' maketime("0202")
#' maketime("1")
#' myvec <- c("0915", "0941", NA, "072200", "0833", "122630", "115500", "1252")
#' maketime(myvec)
#' 
#' @export
maketime <- function(VEC){
  if(any(!(nchar(VEC) == 4 | nchar(VEC) == 6 | is.na(VEC)))){
    stop('this function only accepts NA or strings of length 4 or 6')
  }
  four <- which(nchar(VEC) == 4)
  VEC[four] <- paste0(VEC[four], "00")
  VEC <- gsub('^(.{4})(.*)$', '\\1:\\2', VEC) # add colon to position 5
  VEC <- gsub('^(.{2})(.*)$', '\\1:\\2', VEC) # add colon to position 3
  VEC
}
