plot_qpcr <- function(DT, ...){
  pltlist <- split(DT[, Ct], DT[,template_name])
  par(mar = c(4,6,1,1))
  stripchart(
    lapply(pltlist[gtools::mixedsort(names(pltlist))], function(x) x+1), 
    method = 'jitter', 
    pch = 21, col = hsv(1,0.4,1), lwd = 2, 
    log = 'x', 
    las = 1, 
    ...
    )
  abline(h = 1:length(pltlist), col = grey(0, alpha = 0.2), lty = 3)
  grid()
}
plot_qpcr(rbindlist(res)[Task == 'Unknown',], cex.axis = 0.5)

QR <- rbindlist(res)

QR[Task == 'Unknown', ]

merge(to_pcr, QR[,mean(QuantBackCalc), by = template_name], by.x = 'lab_label', by.y = 'template_name', all.x = TRUE, all.y = FALSE)[,V1]

to_pcr[,lab_label] %in% QR[,template_name]

to_pcr[order(lab_label)]

to_pcr[lab_label]
QR[template_name]

# which templates have been run multiple times
mult_rxns <- QR[ Task == 'Unknown' , uniqueN(plate_id), by = template_name][V1 > 1, template_name]

# how many total rxns of each
QR[template_name %in% mult_rxns, uniqueN(Position), by = template_name] %>% .$V1 %>% table

temp <- QR[template_name %in% mult_rxns, .(template_name = as.factor(template_name), Ct)]
temp[,all(is.na(Ct)),by = template_name]
temp[ ]
pltdat <- split(temp$Ct, temp$template_name)

stripchart(pltdat, cex.axis = 0.8, las = 1, pch = 21, method = 'jitter')
abline(h = 1:length(pltdat), col = grey(0, alpha = 0.2), lty = 3)

grid()
