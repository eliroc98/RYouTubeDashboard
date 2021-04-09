setwd("C:/Users/lizzy/Desktop/Universita/coding for data science and data management/R/project/YouTubeChannels")
source("r_files\\data_gathering_utils.R")
library(httr)
library(rvest)
library(parallel)

#preparing for code optimization
cores <- detectCores()
clusters <- makeCluster(cores-1)

#web scraping to get 100 most subscribed channels
url <- "https://socialblade.com/youtube/top/100/mostsubscribed"
res <- read_html(url) %>%
  html_elements('a') %>%
  html_attr(name="href")

#split links to obtain each part
clusterExport(clusters, c("res"))
results <- parLapply(cl=clusters, 1:length(res), fun= function(x){
  strsplit(res[x],split="/")
stopCluster(clusters)

#prepare dataframe
data <- data.frame(id = 0, 
                   snippet_title = "", 
                   snippet_description = "",
                   snippet_country="",
                   snippet_defaultLanguage="",
                   contentDetails_relatedPlaylists_likes = "",
                   contentDetails_relatedPlaylists_favorites = "",
                   contentDetails_relatedPlaylists_uploads = "",
                   statistics_viewCount = 0,
                   statistics_subscriberCount = 0,
                   statistics_videoCount = 0,
                   topicDetails_topicsIds = "",
                   topicDetails_topicCategories = "",
                   stringsAsFactors=FALSE) })

#debugging indicators
ch<-1
username<-1
search<-1

#list to store channels with no channel list() results
channels_to_search <- c()
i_to_search <- 1

for (i in 1:length(results)){
  result <- results[[i]][[1]]
  if(length(result)>2){
    if(result[2]=="youtube"){
      if(result[3]=="channel"){
        print(paste0("channel ", ch))
        ch <- ch + 1
        channel <- APIgetChannel(result[4])
        data <- rbind(data,getChannel(channel$items[[1]]))
      }
      if(result[3]=="c" || result[3]=="user"){
        #accounting for trapnation
        if(result[4]=="-trapnation"){result[4]<-"trapnation"}
        #accounting for billie eilish
        if(result[4]==""){result[4]<-"billie eilish"}
        
        channel <- APIgetChannelForUsername(result[4])
        print(paste0("Total Results:",channel$pageInfo$totalResults))
        if(channel$pageInfo$totalResults != 0){
          print(paste0("username ", username))
          username<-username + 1
          data <- rbind(data,getChannel(channel$items[[1]]))
        }
        else{
          print(paste0("search ", search))
          search<-search + 1
          channels_to_search[i_to_search] <- result[4]
          i_to_search <- i_to_search + 1
        }
      }
    }
  }
}

#I have to put this aside to not exceed YouTube Data API quota limit per minutes
for(i in 1:length(channels_to_search)){
  channels <- APIsearchChannel(channels_to_search[i])
  channel <- APIgetChannel(channels$items[[1]]$snippet$channelId)
  data <- rbind(data,getChannel(channel$items[[1]]))
}

#removing first entry, which is used to initialise the dataframe
data <- data[-1,]

#saving results
write.csv(data,"C:\\Users\\lizzy\\Desktop\\Universita\\coding for data science and data management\\R\\project\\YouTubeChannels\\data\\dataset.csv", row.names = FALSE)
