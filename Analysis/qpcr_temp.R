plot_qpcr <- function(DT, ...){
  pltlist <- split(DT[, Ct], DT[,template_name])
  par(mar = c(4,6,1,1))
  chartdat <- lapply(pltlist[gtools::mixedsort(names(pltlist))], function(x) x+1)
  mycols <- hsv(h = c(1/8, 0.6), s = 0.7)
  colvec <- rep(2, length(chartdat))
  colvec[grep('^[s|S]t', names(chartdat))] <- 1
  stripchart(
    chartdat, 
    method = 'jitter', 
    pch = 21, lwd = 2, col = mycols[colvec], 
    log = 'x', 
    las = 1, 
    ...
    )
  abline(h = 1:length(pltlist), col = grey(0, alpha = 0.2), lty = 3)
  grid()
}
plot_qpcr(res[[4]])
res[[1]][template_name == '094']
res[[1]][template_name == 'std_1']

plot_qpcr(rbindlist(res)[Task == 'Unknown',], cex.axis = 0.5)

x_in_y <- function(dt1, dt2){
  res[[4]][,template_name] %in% res[[5]][,template_name]
}
x_in_y(res[[4]], res[[5]])

rep(1, 8), rep(2, )
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
library(magrittr)
QR[template_name %in% mult_rxns, uniqueN(Position), by = template_name] %>% .$V1 %>% table

temp <- QR[template_name %in% mult_rxns, .(template_name = as.factor(template_name), plate_id, Ct)]

temp[ , all(is.na(Ct)), by = template_name]

pldat <- temp[ , if(all(!is.na(Ct))) .SD, by = template_name]

library(ggplot2)
myplot <- ggplot(temp, aes(x = template_name, y = Ct, color = plate_id))
myplot + geom_point(shape = 1, stroke = 1.1) + coord_flip() # + geom_jitter()


pltdat <- split(temp$Ct, temp$template_name)

temp
stripchart(pltdat, cex.axis = 0.8, las = 1, pch = 21, method = 'jitter')
abline(h = 1:length(pltdat), col = grey(0, alpha = 0.2), lty = 3)
pltdat

plot(QR[template_name == '094', .(as.factor(plate_id), Ct)])

points(
QR[template_name == '094', .(as.factor(plate_id), Ct)], col = hsv(1,0.5,1), lwd = 2
)



