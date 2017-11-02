plot_stdcurve <- function(qpcrdata, ...){
  pldat <- qpcrdata[Task == "Standard", ]
  plot(x = pldat$Ct, y = pldat$QuantBackCalc, 
       log = 'y', 
       # col = as.numeric(as.factor(pldat$plate_id)), 
       # pch = as.numeric(as.factor(Task)), 
       xlab = expression('C'['t']), ylab = "Concentration (pg/uL)", 
       las = 1
  )
}
plot_stdcurve(qpcrdata = results1)
plot_stdcurve(qpcrdata = results1)

with(qpcr_data[Task == "Standard"], 
     plot(
       QuantBackCalc, Ct, log = 'x', 
       ylim = c(0,50), 
       col = as.numeric(as.factor(pldat$plate_id)), 
       las = 1
       )
     )


model_dat <- results1[Task == "Standard"]
model_out <- lm(formula = Ct ~ log(Quantity), data = model_dat)

stdplot <- function(){
  seqx <- 10^(-6:0)
  plot(
    x = log(seqx), 
    y = seq(from = 0, to = 45, length.out = length(seqx)), 
    ylim = c(0, 45), 
    type = "n", axes = FALSE, ann = FALSE
  )
  axis(1, at = log(seqx), labels = seqx)
  axis(2, las = 1)
  title(xlab = 'Dilution factor', ylab = expression(C[t]))
}
par(mar = c(4,4,1,1))
stdplot()
points(
  log(model_dat$Quantity), model_dat$Ct
  # ylim = c(0, 45), 
  # axes = FALSE, ann = FALSE
  )
axis(1, at = log(model_dat$Quantity), labels = model_dat$Quantity)
axis(2, las = 1)
title(xlab = 'Dilution factor', ylab = expression(C[t]))
abline(model_out, lwd = 2)
INT <- model_out$coefficients["(Intercept)"]
abline(h = INT, col = grey(0.8), lty = 2)
text(
  x = min(log(model_dat$Quantity)), y = INT, 
  labels = round(INT, 1), 
  col = grey(0.8), pos = 2, offset = 2, xpd = TRUE
  )

ptdat <- results2[Task == "Standard"]
points(log(ptdat$Quantity), ptdat$Ct, col = "red")
model_out <- lm(formula = Ct ~ log(Quantity), data = ptdat)
abline(model_out, lwd = 2, col = "red")
model_out$coefficients
# box()




str(model_out)

CT <- model_dat[,Ct]
na.omit(model_dat)


# qpcr notes

# unknown:
conc_in_water <- function(
  vol_field_sample, # {real}
  frac_extracted, # {0,1}
  vol_elute_DNA, 
  vol_into_PCR,
  vol_PCR, 
  conc_out_PCR
){
  
}