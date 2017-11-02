#' Transform response given two linear models
#' 
#' @param x numeric vector of predictor values.
#' @param y numeric vector of response values.
#' @param mod2 object of class lm. Transform y values *to* fit this model.
#' 
#' @return numeric vector of transformed values of y.
#' 
#' @examples 
#' 
#' @export
transform_linear <- function(x, y, mod2){
  mod1 <- lm(y~x)
  int_diff   <- mod2$coefficients[1] - mod1$coefficients[1]
  slope_diff <- mod2$coefficients[2] - mod1$coefficients[2]
  y.prime <- int_diff + y + x*slope_diff
  return(y.prime)
}
