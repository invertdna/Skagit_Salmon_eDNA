# create a base plot for qPCR standard curve plot
stdplot <- function(cycles = 45, dil.factors = 10^(-7:0)){
  seqx <- dil.factors
  plot(
    x = log10(seqx), 
    y = seq(from = 0, to = cycles, length.out = length(seqx)), 
    ylim = c(0, cycles), 
    type = "n", axes = FALSE, ann = FALSE
  )
  axis(1, at = log10(seqx), labels = seqx)
  axis(2, las = 1)
  title(xlab = 'Dilution factor', ylab = expression(C[t]))
}
