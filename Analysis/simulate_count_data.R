# simulate count data

# source: http://stats.stackexchange.com/questions/9767/generating-over-dispersed-counts-data-with-serial-correlation

rho_vals <- seq(from = 0.1, to = 0.8, by = 0.1)
y <- list()
for(i in 1:length(rho_vals)){
N <- 100
rho <- rho_vals[i]
log.lambda <- 1 + arima.sim(model = list(ar=rho), n = N)
y[[i]] <- rpois(N, lambda = exp(log.lambda))
}
boxplot(y)