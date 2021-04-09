library(parallel)

#preparing for code optimization/bootstrapping
cores <- detectCores()

#function to exctract a statistic given an input specification
which_stat <- function(x,stat){
  switch(stat,
         "median"={
           return(median(x,na.rm=T))
         },
         "mean"={
           return(mean(x,na.rm=T))
         },
         "variance"={
           return(var(x,na.rm=T))
         })
}

#function to compute statistics variances using bootstrapping technique
summary_stats <- function(stat, variable){
  clusters <- makeCluster(cores-1)
  clusterExport(clusters,c("stat","variable","which_stat"),envir=environment())
  stat_boot <- parLapply(clusters, 1:5000, function(i) { 
    x <- sample(variable, replace = TRUE)
    which_stat(x,stat)
  })
  stopCluster(clusters)
  return(stat_boot)
}

#function to get the final table, which will be displayed in the shiny app
summary_stats_table <- function(data,variables,stats,progress){
  rnames<-list()
  df <- data.frame()
  for(j in 1:length(stats)){
    progress$inc(1/length(stats), detail = paste(j,"/",length(stats)))
    ls <- list()
    cf <- list()
    for (i in 1:length(variables)){
      s <- summary_stats(stats[j],data[,variables[i]])
      which_s <- which_stat(data[,variables[i]],stats[j])
      q <- paste(quantile(unlist(s), c(0.025, 0.975)), collapse=",")
      ls[length(ls)+1]<-which_s
      cf[length(cf)+1]<-paste0("[",q,"]",sep="")
    }
    df <- rbind(df,ls) 
    rnames[length(rnames)+1]<-stats[j]
    df <- rbind(df,cf) 
    rnames[length(rnames)+1]<-paste(stats[j]," confidence int. (95%)", collapse = "")
  }
  colnames(df)<-variables
  row.names(df)<-rnames
  return(df)
}




