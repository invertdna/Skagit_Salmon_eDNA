
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
