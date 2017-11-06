#' Calculate efficiency of qPCR reaction based on standard curve
#' 
#' @param slope Slope of standard curve in log10 space
#' 
#' @examples PCRefficiency(-4)
#' 
#' @references Bustin et al. 2009 Clinical Chemistry. (MIQE guidelines)
#' 
#' @export
PCRefficiency <- function(slope){
  (10^(-1/slope))-1
}