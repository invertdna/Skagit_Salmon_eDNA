results3 <- load_qpcr(
  std_conc = 1, 
  qpcr_data_file = "../Data/qpcr/CKCO3-170712/results/results_table.txt", 
  sample_sheet_file = "../Data/qpcr/CKCO3-170712/setup/sample_sheet.csv"
)

R3 <- results3
R3[, logQuant := log(Quantity)]

mycols <- gghue(2)
mycols <- hsv(h = c(1, 1/8, 0.6), s = 0.7)

stdplot()
with(R3, points(logQuant, Ct, col = mycols[as.numeric(as.factor(R3[,Task]))], lwd = 2))
with(R3, plot(logQuant, Ct, col = mycols[as.numeric(as.factor(R3[,Task]))], lwd = 2))
plot(R3[,Ct], col = mycols[as.numeric(as.factor(R3[,Task]))], lwd = 3)

R3 <- R3[Task != "NTC", ]

with(R3, plot(logQuant, Ct, col = mycols[as.numeric(as.factor(Task))], lwd = 2))
with(R3, 
  plot(
    as.numeric(as.factor(template_name)), 
    Ct, 
    col = mycols[as.numeric(as.factor(Task))], lwd = 2
))
R3[,as.numeric(as.factor(template_name))]
R3
abline(v = 1:20, col = grey(0.8, alpha = 0.5))
R3[, .N, by = as.numeric(as.factor(template_name))]

with(R3, points(logQuant, Ct, col = mycols[as.numeric(as.factor(DT[,Task]))], lwd = 2))
