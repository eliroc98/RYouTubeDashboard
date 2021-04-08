setwd("C:/Users/lizzy/Desktop/Universita/coding for data science and data management/R/project/YouTubeChannels")
library(Rcpp)

#import data: data acquisition is performed once because of the YouTube API limit quota
data <- read.csv(file = 'data\\dataset.csv')
topicIds <- read.csv(file = 'data/topicIds.csv', sep=";")
topicNames <- topicIds$topic
names(topicNames) <- topicIds$ï..id

data$youtube_playlist <- rep(0,nrow(data))
data[data$statistics_viewCount==0,]$youtube_playlist<-1

#try to rccp
cppFunction('List topicTranslation (DataFrame df){
            Environment pkg = Environment::namespace_env("base");
            Function strsplit = pkg["strsplit"];
            Function print = pkg["print"];
            List split = strsplit(df[0,11]," ");
            for(int i = 0; i<split.length();i++){
              List sub_split = strsplit(split[i]," ");
              print(sub_split.length());
              for(int j = 0; j<sub_split.length();j++){
                print(sub_split[j]);
                string topic = sub_split[j];
                if(topic in df.names())
              }
            }
            return split;}')

s<-topicTranslation(data)
#______________________________

for(i in 1:nrow(data)){
  split <- strsplit(data[i,]$topicDetails_topicsIds,split=" ")
  for(j in 1:length(split)){
    topic <- split[[1]][[j]]
    if(!is.na(topic)){
      if(topicNames[topic] %in% colnames(data)){
        data[i,][topicNames[topic]] <- 1
      }
      else{
        data[topicNames[topic]] <- rep(0,nrow(data))
        data[i,][topicNames[topic]] <- 1
      }
    }
  }
}

#saving results
write.csv(data,"C:\\Users\\lizzy\\Desktop\\Universita\\coding for data science and data management\\R\\project\\YouTubeChannels\\data\\dataset_adjusted.csv", row.names = FALSE)





#code for categories: repetitive
#split <-strsplit(data[i,]$topicDetails_topicCategories,split=" ")
#for(j in 1:length(split)){
#  category <- strsplit(split[[1]][[j]],split="/")
#  category<-category[[1]][[length(category[[1]])]]
#  if(category %in% colnames(data)){
#    data[i,][[category]] <- 1
#  }
#  else{
#    data[[category]] <- rep(0,nrow(data))
#    data[i,][[category]] <- 1
#  }
#}
  
