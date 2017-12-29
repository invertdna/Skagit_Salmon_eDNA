R3 <- load_qpcr(
  qpcr_data_file = "../Data/qpcr/CKCO3-170712/results/results_table.txt", 
  sample_sheet_file = "../Data/qpcr/CKCO3-170712/setup/sample_sheet.csv", 
  std_conc = 1
)

R3[, logQuant := log(Quantity)]

mycols <- hsv(h = c(1/8, 0.6), s = 0.7)

stdplot()
with(R3, points(logQuant, Ct, col = mycols[as.numeric(as.factor(R3[,Task]))], lwd = 2))
with(R3, plot(logQuant, Ct, col = mycols[as.numeric(as.factor(Task))], lwd = 2))
plot(R3[,Ct], col = mycols[as.numeric(as.factor(R3[,Task]))], lwd = 3)

with(R3, stripchart(Ct ~ template_name,  method = 'jitter', las = 1))
with(R3, abline(h = 1:length(unique(template_name)), col = grey(0, 0.2), lty = 2))
with(R3, 
  plot(
    as.numeric(as.factor(template_name)), 
    Ct, 
    col = mycols[as.numeric(as.factor(Task))], lwd = 2
))
abline(v = 1:20, col = grey(0.8, alpha = 0.5))
R3[, .N, by = as.numeric(as.factor(template_name))]

with(R3, points(logQuant, Ct, col = mycols[as.numeric(as.factor(R3[,Task]))], lwd = 2))


# To deal with weird data files (multiple reporters/assays):
thefile <- "/Users/jimmy.odonnell/qpcr_data/Jimmy_Batch_Export/CYAGCYTB-170829-A/results/CYAGCYTB-170829-A_result.txt"

thefile <- normalizePath(thefile)

START <- 11
STOP <- 35
thecall <- paste0("sed -n ", '"', START, ",", STOP, 'p" ', thefile)
fread(thecall)
dat <- load_qpcr(thecall)

stdat <- dat[Task == "Standard", ]

model_dat <- list()
model_dat[[1]] <- stdat

model_out <- list()
for(i in 1:length(model_dat)){
  model_out[[i]] <- lm(formula = Ct ~ log10(Quantity), data = model_dat[[i]])
}
# GOTO qpcr_analysis for plotting

# get the names of samples for which all replicates worked
worked <- R4[,!any(is.na(Ct)),by = template_name][V1 == TRUE,template_name]
good_Cts <- with(R4[template_name %in% worked, ], split(Ct, template_name))
stripchart(good_Cts, las = 1)
R4[template_name == "St4", max(Ct)]
R4[Ct < 33 & template_name %in% worked, ]
abline(h = 1:length(good_Cts), col = grey(0.9))
abline(v = 33, col = hsv(h = 1/8, s = 0.7), lwd = 2, lty = 2)
stripchart(good_Cts, las = 1, add = TRUE)


with(
na.omit(R4[,.(Ct.mean = mean(Ct), Ct.sd = sd(Ct)),by = template_name]), 
 plot(Ct.mean, Ct.var)
)
