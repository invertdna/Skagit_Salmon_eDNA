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


# extract just the counts
plot_dat <- catch_data[,3:ncol(catch_data)]

# order by total count
plot_dat <- plot_dat[,order(colSums(plot_dat))]

# add 1 so log scale works
plot_dat <- plot_dat + 1

# plot
op <- par()
par(mar = c(4,8,1,1))
boxcols <- c('turquoise', 'mediumpurple', 'hotpink')
boxplot(plot_dat, log = "x", 
  border = boxcols, medcol = 1,
  # border = hsv(h = seq(0,1,0.1), s = 1, v = 0.8, alpha = 1), 
  las = 1, horizontal = TRUE
)

# add guide lines
abline(h = 1:(ncol(catch_data)-2), lty = 2, col = hsv(1,1,0,alpha = 0.2))

par(op)

