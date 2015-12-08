require(AUC)
require(grid)
require(ggplot2)

#..from http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_%28ggplot2%29/
# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

#..AUC score calculator: 
AucCalc <- function(preds, labels){ 
  sens <- sensitivity(preds, factor(labels))
  auc(sens)
}

#..Weighted Gini scoring (thanks Kaggles)
WeightedGini <- function(solution, weights, submission){
  df = data.frame(solution = solution, weights = weights, submission = submission)
  df <- df[order(df$submission, decreasing = TRUE),]
  df$random = cumsum((df$weights/sum(df$weights)))
  totalPositive <- sum(df$solution * df$weights)
  df$cumPosFound <- cumsum(df$solution * df$weights)
  df$Lorentz <- df$cumPosFound / totalPositive
  n <- nrow(df)
  sum(df$Lorentz[-1]*df$random[-n]) - sum(df$Lorentz[-n]*df$random[-1])
}

NormalizedWeightedGini <- function(solution, weights, submission) {
  WeightedGini(solution, weights, submission) / WeightedGini(solution, weights, solution)
}

#..simple average blend testing
alphaTester <- function( 
  alphas = seq(0, 1, 0.02), 
  alphaVec = rfs, 
  compVec = logs, 
  truth = train1$fire, 
  test = 'auc', 
  weights = 1
){ 
  
  if(test == 'rss'){ 
    output <- sapply(alphas, function(ALPHA){ 
      preds <- ALPHA*alphaVec + (1 - ALPHA)*compVec
      mean((preds - as.numeric(as.character(truth)))^2)
    })
    print(paste0('optimized at alpha = ', alphas[which(output == min(output))]))
  } else if(test == 'gini') { 
    output <- sapply(alphas, function(ALPHA){ 
      preds <- ALPHA*alphaVec + (1 - ALPHA)*compVec
      NormalizedWeightedGini(truth, weights, preds)
    })
    print(paste0('optimized at alpha = ', alphas[which(output == max(output))]))
  } else if(test == 'llfun'){ 
    output <- sapply(alphas, function(ALPHA){ 
      preds <- ALPHA*alphaVec + (1 - ALPHA)*compVec
      llfun(truth, preds)
    })
    print(paste0('optimized at alpha = ', alphas[which(output == min(output))]))
  } else if(test == 'auc'){ 
    
    output <- sapply(alphas, function(ALPHA){ 
      preds <- ALPHA*alphaVec + (1 - ALPHA)*compVec
      AucCalc(preds, truth)
    })
    print(paste0('optimized at alpha = ', alphas[which(output == max(output))]))
    
  }
  
  output
}

#..one hot encoding of categorical features
OneHotEncode <- function(indata){
    char.vars <- sapply(indata, is.character)
    fact.data <- indata[char.vars]
    fact.data[] <- lapply(fact.data, factor)
    
    fact.data <- as.data.frame(model.matrix( ~ . - 1, data = fact.data,
    contrasts.arg = lapply(fact.data, contrasts, contrasts = FALSE)))
    
    #TODO We can do regular expressions to rename columns according to a different convention that makes them easier to split on
    
    out.data <- indata[!char.vars]
    cbind(out.data, fact.data)
    
}

CharToNum <- function(indata, fields){ 
  indata[fields] <- lapply(indata[fields], as.numeric)
  indata 
}

NumToCat <- function(indata, fields, missing_vals){ 
  indata[fields] <- lapply(indata[fields], as.character)
  indata[fields] <- lapply(indata[fields], function(x){ 
    x[is.na(x)] <- 'na'
    x[x %in% missing_vals] <- 'na'
    x
  })
  indata
}

Formatter <- function(indata, ...){
  for(fun in list(...)){
    indata <- fun(indata)
    cat('dim formatted data: [', dim(indata), ']\n', sep = ' ')
  }
  indata
}

scorefunction    <- function(x, nbins) as.numeric(cut(x, quantile(x, seq(0, 1, (1/nbins))), labels = 1:nbins, include.lowest = TRUE))

CorClean <- function(indata, varlist, thresh){
  orig <- varlist
  while(length(varlist) > 1){ 
    var <- varlist[1]
    varlist  <- varlist[-1]
    print(var)
    othercors  <- as.data.frame(cor(indata[[var]], indata[varlist], use = "pairwise.complete.obs"))
    varstokill <- names(othercors)[othercors >= thresh]
    if(length(varstokill) > 0){
      cat('\n Removing: [', paste(varstokill, collapse = ', '), ']\n', sep = '')
      for(gonevar in varstokill) indata[gonevar] <- NULL
    }
    varlist <- varlist[varlist %in% names(indata)]
  }  
  orig[orig %in% names(indata)] 
}