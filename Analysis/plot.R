#-------------------------------------------------------------------------------
# PLOTTING
plot_name <- "depth_by_carat"

EXPORT <- TRUE

if(!exists("legend_text")){legend_text <- list()}
legend_text[plot_name] <- {"
This is the text of the legend.
"}

if(EXPORT){
  pdf_file    <- file.path(fig_dir, paste(plot_name, ".pdf", sep = ""))
  legend_file <- file.path(fig_dir, paste(plot_name, "_legend.txt", sep = ""))
  writeLines(legend_text[[plot_name]], con = legend_file)
  pdf(file = pdf_file, width = 5, height = 4) #, width = 8, height = 3
}

par(mar = c(4,4,1,7), xpd = TRUE)

# the_layout <- layout(mat = matrix(c(1,2), nrow = 1), widths = c(11,6))
# margins_subplot <- list(c(4,5,3,5), c(4,0,3,3), c(4,0,3,3))


point_colors <- gghue(nlevels(diamonds1K$cut), alpha = 1)
plot(
  x = diamonds1K$carat, 
  y = diamonds1K$depth, 
  xlab = "Carat",
  ylab = "Depth", 
  col = point_colors[diamonds1K$cut], 
  las = 1
)
legend("right", inset = c(-0.5,0), 
  legend = levels(diamonds1K$cut), col = point_colors,
  pch = 1, title="Cut", bty = "n")
plot_model(model_out$conf, pred_vec = carat_pred, line_color = "black")
# color_legend(col = point_colors, lev = levels(diamonds1K$cut))

if(EXPORT){
  dev.off()
}
