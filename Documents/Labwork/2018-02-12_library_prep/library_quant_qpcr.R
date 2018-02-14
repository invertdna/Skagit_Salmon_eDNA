library(data.table)

thefile <- '~/Desktop/KapaQuant-20180213/KapaQuant-20180213.txt'

dt <- fread(thefile)

dt

tokeep <- c('Position','Flag','Sample','Detector','Task','Ct','Quantity')

dt <- dt[ , c(tokeep), with = FALSE]

dt <- dt[Detector != "", ]

dt[,Ct := as.numeric(Ct)]

with(dt, 
  plot(x = Quantity, y = Ct, 
       log = 'x', las = 2,
       col = as.numeric(as.factor(Task)), 
       xlim = c(1e-4, 20), ylim = c(1, 25)
       )
)

coeffs <- rep(c(1e3, 2e3, 4e3, 8e3), each = 3)
ests <- dt[Task == 'Unknown', Quantity] * coeffs

size_correction <- (452/514)

corrected_molarity <- ests*size_correction

mean(corrected_molarity[1:3])

pldat <- base::split(ests, coeffs)

stripchart(pldat, pch = 21,  lwd = 2, las = 1)
boxplot(pldat, las = 1)
