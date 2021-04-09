setwd("C:/Users/lizzy/Desktop/Universita/coding for data science and data management/R/project/YouTubeChannels")

#import data: data acquisition is performed once because of the YouTube API limit quota
data <- read.csv(file = 'data\\dataset.csv')
topicIds <- read.csv(file = 'data/topicIds.csv', sep=";")
topicNames <- topicIds$topic
names(topicNames) <- topicIds$ï..id

#creating dummy to distinguish which channel is a Youtube-created playlist and which is not
data$youtube_playlist <- rep(0,nrow(data))
data[data$statistics_viewCount==0,]$youtube_playlist<-1

#creating dummies for topics
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
