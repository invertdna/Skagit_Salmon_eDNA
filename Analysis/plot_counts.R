counts_net

split_sp_by_site <- function(data, sp){
  x <- data[data$species == sp, ]
  split(x$count, x$site)
}

split_sp_by_season <- function(data, sp){
  x <- data[data$species == sp, ]
  split(x$count, x$season)
}


boxplot(split_sp_by_site(counts_net, "Cymatogaster aggregata"))
boxplot(split_sp_by_season(counts_net, "Cymatogaster aggregata"))

boxplot(split_sp_by_season(counts_net, "Oncorhynchus tshawytscha"))
