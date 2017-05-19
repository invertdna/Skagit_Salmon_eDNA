

#-------------------------------------------------------------------------------
# make up some coefficients
#-------------------------------------------------------------------------------
coefficients <- list()

# I think months have a big impact on how many salmon are in the water:
# keep in mind this built-in: month.name
coefficients[["month"]] <- c(
  "Jan" = 0, 
  "Feb" = 100, 
  "Mar" = 1000, 
  "Apr" = 500,
  "May" = 200, 
  "Jun" = 50, 
  "Jul" = 0, 
  "Aug" = 0, 
  "Sep" = 0, 
  "Oct" = 0, 
  "Nov" = 0, 
  "Dec" = 0
)

# Sites also probably matter: big rivers have more salmon than small ones
coefficients[["site"]] <- c(
  "XS" = 0, 
  "S"  = 1, 
  "M"  = 10, 
  "L"  = 100, 
  "XL" = 1000
)


coef_df <- expand.grid(lapply(coefficients, names))
coef_df[,3:4] <- expand.grid(coefficients[["month"]], coefficients[["site"]])
coef_df$mu <- apply(X = coef_df[,3:4], MARGIN = 1, FUN = prod)
colnames(coef_df)[3:4] <- c("month.coef", "site.coef")

# from that, simulate the "TRUE" number of fish at each site:
countsTruth <- data.frame(
  month = coef_df$month, 
  site = coef_df$site, 
  count = rnbinom(n = nrow(coef_df), size = 10, mu = coef_df$mu) 
)

#-------------------------------------------------------------------------------
# NET CATCH DATA
#-------------------------------------------------------------------------------
# from the "TRUTH", simulate some catches of fish at each site:
# the net can only catch some fraction of the total fish at a given site
net_efficiency <- 0.01

# number of samples (i.e. net tows) per event (i.e. visit to a site)
samp_per_event <- 5

total_samples  <- nrow(countsTruth) * samp_per_event
sample_lambdas <- rep(countsTruth$count * net_efficiency, each = samp_per_event)
counts_net <- rpois(n = total_samples, lambda = sample_lambdas)
catch_data_sim <- data.frame(
  month   = rep(countsTruth$month, each = 5), 
  site    = rep(countsTruth$site, each = 5), 
  rep.net = rep(1:5, length.out = 300), 
  count = counts_net
)

EXPORT <- TRUE
if(EXPORT){
  write.csv(catch_data_sim, 
    row.names = FALSE,
    file = file.path(data_dir, "catch_data_sim.csv")
  )
}

#-------------------------------------------------------------------------------
# OLD:
#-------------------------------------------------------------------------------
# make up some data
EXPORT <- FALSE

site_names <- sites$site_name

species <- c(
  "Oncorhynchus tshawytscha",
  "Oncorhynchus nerka",
  "Oncorhynchus kisutch",
  "Oncorhynchus gorbuscha",
  "Ammodytes hexapterus",
  "Clupea pallasii",
  "Engraulis mordax",
  "Cymatogaster aggregata", 
  "Gasterosteus aculeatus",
  "Hypomesus pretiosus",
  "Mallotus villosus"
)

season <- c("Summer") # , "Winter1", "Winter2"

raw_counts <- integer()
for(s in 1:length(season)){
  for(i in 1:length(site_names)){
    # simulate count data
    N <- length(species)
    rho <- 0.1
    log.lambda <- 1 + arima.sim(model=list(ar=rho), n=N)
    y <- rpois(N, lambda=exp(log.lambda))
    raw_counts <- c(raw_counts, y)
  }
}


counts_net <- data.frame(
  season  = rep(season, each = length(site_names)*length(species)),
  site    = rep(rep(site_names, each = length(species)), each = length(season)),
  species = rep(species, times = length(site_names)*length(season)),
  count   = raw_counts
)

if(EXPORT){
  write.csv(counts_net, file = file.path(data_dir, "counts_net_fake.csv"))
}
