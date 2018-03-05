# Analyze qPCR data, especially 
model_dat <- list()
for(i in seq(res)){ # object 'res' from qpcr_load.R
  model_dat[[i]] <- res[[i]][Task == "Standard"]
}

model_out <- list()
for(i in 1:length(model_dat)){
  model_out[[i]] <- lm(formula = Ct ~ log10(Quantity), data = model_dat[[i]])
}

par(mar = c(4,4,1,1))
stdplot(cycles = 45, dil.factors = 10^(-7:0))
mycol.h <- gghue(length(model_dat))
mycol.l <- gghue(length(model_dat), alpha = 0.5)
for(i in 1:length(model_dat)){
  points(model_dat[[i]][,log10(Quantity)], model_dat[[i]][,Ct], col = mycol.l[i])
  abline(model_out[[i]], lwd = 2, col = mycol.h[i])
  INT <- model_out[[i]]$coefficients["(Intercept)"]
  SLO <- model_out[[i]]$coefficients[2]
  text.coeff <- paste0(round(INT,1), " (", round(SLO, 2), ")")
  abline(h = INT, lty = 2, col = mycol.l[i])
  text(x = log10(10^-7), y = INT, labels = text.coeff, 
    col = mycol.h[i], adj = c(0,-0.2), #pos = 3, offset = 0.1, 
    xpd = TRUE)
}
plate_ids <- sapply(model_dat, function(x) x[,unique(plate_id)])
leg.text  <- plate_ids
legend('topright', 
  legend = leg.text, pch = 1, 
  col = mycol.h, text.col = mycol.h, 
  bty = 'n'
)
# box(col = grey(0.8))
demo_transform <- FALSE
if(demo_transform){
  mod <- 1
  othermod <- function(i){if(i == 1) return(2) else if(i == 2) return(1)}
  mydat <- na.omit(model_dat[[mod]][,.(Quantity, Ct)])
  y3 <- transform_linear(
    x = mydat[,log(Quantity)], 
    y = mydat[,Ct], 
    mod2 = model_out[[othermod(mod)]]
  )
  points(x = mydat[,log(Quantity)], y = y3, pch = 19)
  abline(lm(y3 ~ mydat[,log(Quantity)]), col = "green", lwd = 3)
}

# TODO things to think about:
conc_in_water <- function(
  vol_field_sample, # {real}
  frac_extracted, # {0,1}
  vol_elute_DNA, 
  vol_into_PCR,
  vol_PCR, 
  conc_out_PCR
){}