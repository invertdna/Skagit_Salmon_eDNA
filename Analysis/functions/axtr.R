axtr <- function(x, ladj){
  # transform data and make corresponding axis ticks and labels
  out <- list()
  out[['trans']] <- log(x + ladj)
  lab_raw <- exp(pretty(out[['trans']])) - ladj
  out[['lab']] <- round(lab_raw)
  out[['tick']] <- log(out[['lab']] + ladj)
  return(out)
}
