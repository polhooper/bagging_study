pkg_list <- c('ggplot2', 'plyr', 'dplyr', 'AUC', 'scales', 'RColorBrewer', 'reshape2', 'readr', 'parallel')
if(any(!pkg_list %in% installed.packages()[, 1])) install.packages(pkg_list[!pkg_list %in% installed.packages()[, 1]], repos='http://cran.us.r-project.org')
sapply(pkg_list, require, character.only = TRUE)

source('utils/r_utils.R')

#..creat graph directory if it doesn't exist
#-------------------------------------------
graph_dir <- file.path(getwd(), 'graphics')
if(!exists(graph_dir)) dir.create(graph_dir)

#..define a couple helper functions
#----------------------------------
PlotTabber <- function(indata, nbins, truths){ 
  avgs <- lapply(indata, function(x) tapply(truths, scorefunction(-x, nbins = nbins), mean))
  #avgs <- lapply(avgs, function(x) round(cumsum(x)/(1:length(x)), 4))
  plot_tab <- do.call('cbind.data.frame', avgs)
  do.call('rbind.data.frame', lapply(names(plot_tab), function(x){
    rate <- plot_tab[[x]]
    data.frame(
      model = x, 
      rate = rate,
      cumrate = cumsum(rate)/(1:length(rate)),
      bin = 1:nrow(plot_tab))
  }))
}

GainCast <- function(indata){
  #..this works on a data object that has first been processed with PlotTabber 
  ddply(indata, .(model), function(SUBSET){
    SUBSET$rate <- cumsum(SUBSET$rate)
    SUBSET$rate <- SUBSET$rate/(max(SUBSET$rate))
    
    addrow <- SUBSET[1, ]
    addrow$rate <- 0 
    addrow$bin <- 0 
    
    SUBSET <- rbind(addrow, SUBSET)
    SUBSET
  })
}

GainPlot <- function(indata, title, nbins, colors){ 
  p <- ggplot(indata, aes(x = bin, y = rate, color = model)) + 
    geom_point() + 
    geom_line(size = 2) + 
    geom_abline(intercept = 0, slope = 1/10, color = 'grey60', size = 1, linetype = 2) + 
    scale_x_continuous(breaks = 0:nbins, labels = paste0(10*(0:nbins), '%'), name = '% Customers Contacted') + 
    scale_y_continuous(breaks = seq(0, 1, 0.1), labels = percent, name = '% Positive Responses') + 
    scale_color_manual(values = colors, name = '') + 
    theme(text = element_text(size = 15)) +
    ggtitle(title)
  return(p)
}

LiftPlot <- function(indata, title, nbins, colors, truths){
  p <- ggplot(indata, aes(x = bin, y = cumrate, color = model)) + 
    geom_point() + 
    geom_line(size = 2) + 
    geom_abline(intercept = mean(truths), slope = 0, color = 'grey60', size = 1, linetype = 2) + 
    scale_x_continuous(breaks = 0:nbins, labels = paste0(10*(0:nbins), '%'), name = '% Customers Contacted') + 
    scale_y_continuous(breaks = seq(min(indata$cumrate), max(indata$cumrate), length.out = 10), labels = percent, name = 'Observed response rate (%)') + 
    scale_color_manual(values = colors, name = '') + 
    theme(text = element_text(size = 15)) +
    ggtitle(title)
  return(p)
}

#..import predictions and truths 
#-------------------------------
file_list <- dir()
file_list <- file_list[grepl('_preds', file_list)]
pred_frame <- do.call('cbind.data.frame', lapply(file_list, function(x) read.table(x, header = FALSE)[, 1]))
names(pred_frame) <- gsub('_preds\\.txt', '', file_list)
truths <- read.table('truths.txt', header = FALSE)[, 1]

#..life chart, OLS models only
#-----------------------------
tmp <- select(pred_frame, lm, lm_bagged)
plot_tab <- PlotTabber(tmp, 10, truths)
color_vals <- c(brewer.pal(length(unique(plot_tab$model)), "Accent"))[-3]

p1 <- LiftPlot(
  indata = plot_tab, 
  title = 'Comparison of lift curves for a simple linear regression\nversus an ensemble of patched linear regressions', 
  nbins = 10, 
  colors = color_vals, 
  truths = truths)

png(file.path(graph_dir, 'lift_ols.png'), width = 700, height = 400)
  print(p1)
dev.off()

#..cumulative gains chart, OLS models
#------------------------------------
gain_tab <- GainCast(plot_tab)
p2 <- GainPlot(
  indata = gain_tab, 
  title = 'Comparison of cumulative gains curves for a simple linear regression\n versus an ensemble of patched linear regressions', 
  nbins = 10, 
  colors = color_vals)

png(file.path(graph_dir, 'gain_ols.png'), width = 700, height = 600)
  print(p2)
dev.off()

#..lift chart, all models
#------------------------
tmp <- select(pred_frame, lm, lm_bagged, log, rf)
plot_tab <- PlotTabber(tmp, 10, truths)
color_vals <- c(brewer.pal(length(unique(plot_tab$model)), "Accent"))

p3 <- LiftPlot(
  indata = plot_tab, 
  title = 'Comparison of lift curves for random forest, linear model,\n logistic model and bagged linear model', 
  nbins = 10, 
  colors = color_vals, 
  truths = truths)

png(file.path(graph_dir, 'lift_all.png'), width = 700, height = 400)
  print(p3)
dev.off()

#..cumulative gains chart, all models
#------------------------------------
gain_tab <- GainCast(plot_tab)
color_vals <- c(brewer.pal(length(unique(plot_tab$model)), "Accent"))

p4 <- GainPlot(
  indata = gain_tab, 
  title = 'Cumulative gains curves for random forest, linear model,\n logistic model and bagged linear model', 
  nbins = 10, 
  colors = color_vals)

png(file.path(graph_dir, 'gain_all.png'), width = 700, height = 600)
  print(p4)
dev.off()
