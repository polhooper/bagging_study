pkg_list <- c('ggplot2', 'plyr', 'dplyr', 'AUC', 'scales', 'RColorBrewer', 'reshape2', 'readr', 'parallel')
if(any(!pkg_list %in% installed.packages()[, 1])) install.packages(pkg_list[!pkg_list %in% installed.packages()[, 1]])
sapply(pkg_list, require, character.only = TRUE)

source('utils/r_utils.R')

PlotTabber <- function(indata, nbins, truths){ 
  avgs <- lapply(indata, function(x) tapply(truths, scorefunction(-x, nbins = nbins), mean))
  plot_tab <- do.call('cbind.data.frame', avgs)
  do.call('rbind.data.frame', lapply(names(plot_tab), function(x) data.frame(model = x, rate = plot_tab[[x]], bin = 1:nrow(plot_tab))))
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

nbins <- 10 
p1 <- ggplot(plot_tab, aes(x = bin, y = rate, color = model)) + 
  geom_point() + 
  geom_line(size = 1) + 
  geom_abline(intercept = mean(plot_tab$rate), slope = 0, color = 'grey60', size = 1, linetype = 2) + 
  scale_x_continuous(breaks = 1:nbins, labels = 1:nbins, name = 'Decile bin for each predictive model') + 
  scale_y_continuous(breaks = seq(min(plot_tab$rate), max(plot_tab$rate), 0.002), labels = percent, name = 'Observed response rate (%)') + 
  scale_color_manual(values = color_vals) + 
  ggtitle('Comparison of lift curves for a simple linear regression\nversus an ensemble of patched linear regressions')
png('lift_ols.png', width = 1000, height = 700)
  print(p1)
dev.off()

#..cumulative gains chart, OLS models
#------------------------------------
gain_tab <- GainCast(plot_tab)
nbins <- 10 
p2 <- ggplot(gain_tab, aes(x = bin, y = rate, color = model)) + 
  geom_point() + 
  geom_line(size = 1) + 
  geom_abline(intercept = 0, slope = 1/10, color = 'grey60', size = 1, linetype = 2) + 
  scale_x_continuous(breaks = 1:nbins, labels = paste0(10*(1:nbins), '%'), name = '% Customers Contacted') + 
  scale_y_continuous(breaks = seq(0, 1, 0.1), labels = percent, name = '% Positive Responses') + 
  scale_color_manual(values = color_vals) + 
  ggtitle('Comparison of cumulative gains curves for a simple linear regression\n versus an ensemble of patched linear regressions')
png('gain_ols.png', width = 800, height = 700)
  print(p2)
dev.off()

#..lift chart, all models
#------------------------
tmp <- select(pred_frame, lm, lm_bagged, log, rf)
plot_tab <- PlotTabber(tmp, 10, truths)

color_vals <- c(brewer.pal(length(unique(plot_tab$model)), "Accent"))
nbins <- 10 
p3 <- ggplot(plot_tab, aes(x = bin, y = rate, color = model)) + 
  geom_point() + 
  geom_line(size = 1) + 
  geom_abline(intercept = mean(plot_tab$rate), slope = 0, color = 'grey60', size = 1, linetype = 2) + 
  scale_x_continuous(breaks = 1:nbins, labels = 1:nbins, name = 'Decile bin for each predictive model') + 
  scale_y_continuous(breaks = seq(min(plot_tab$rate), max(plot_tab$rate), 0.002), labels = percent, name = 'Observed response rate (%)') + 
  scale_color_manual(values = color_vals) + 
  ggtitle('Comparison of lift curves for random forest, linear model, and bagged linear model')
png('lift_all.png', width = 1000, height = 700)
  print(p3)
dev.off()

#..cumulative gains chart, all models
#------------------------------------
gain_tab <- GainCast(plot_tab)
color_vals <- c(brewer.pal(length(unique(plot_tab$model)), "Accent"))
nbins <- 10 
p4 <- ggplot(gain_tab, aes(x = bin, y = rate, color = model)) + 
  geom_point() + 
  geom_line(size = 1) + 
  geom_abline(intercept = 0, slope = 1/10, color = 'grey60', size = 1, linetype = 2) + 
  scale_x_continuous(breaks = 1:nbins, labels = paste0(10*(1:nbins), '%'), name = '% Customers Contacted') + 
  scale_y_continuous(breaks = seq(0, 1, 0.1), labels = percent, name = '% Positive Responses') + 
  scale_color_manual(values = color_vals) + 
  ggtitle('Cumulative gains curves for random forest, linear model, and bagged linear model')
png('gain_all.png', width = 800, height = 700)
  print(p4)
dev.off()
