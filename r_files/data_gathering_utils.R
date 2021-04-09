key <- "AIzaSyCjL_9ED77w-E3z4GiQECmREv7-TdQJ6ds"

#function to convert resulting NULLs in R NA
checkAndReplaceNull <- function(item, type = "string"){
  switch(
    type,
    "string"= return(if (is.null(item)) NA else item),
    "integer"= return(if (is.null(item)) NA else as.numeric(item)),
    "list"= return(if (is.null(item)) NA else paste(item, collapse = " "))
  )
}

#function which serves as "builder" to get the right row format to put into the dataset
getChannel <- function(raw_item){
  id <- checkAndReplaceNull(raw_item$id)
  snippet_title <- checkAndReplaceNull(raw_item$snippet$title)
  snippet_description <- checkAndReplaceNull(raw_item$snippet$description)
  snippet_country <- checkAndReplaceNull(raw_item$snippet$country)
  snippet_defaultLanguage <- checkAndReplaceNull(raw_item$snippet$defaultLanguage)
  contentDetails_relatedPlaylist_likes <- checkAndReplaceNull(raw_item$contentDetails$relatedPlaylists$likes)
  contentDetails_relatedPlaylist_favourites <- checkAndReplaceNull(raw_item$contentDetails$relatedPlaylists$favorites)
  contentDetails_relatedPlaylist_uploads <-  checkAndReplaceNull(raw_item$contentDetails$relatedPlaylists$uploads)
  statistics_viewCount <- checkAndReplaceNull(raw_item$statistics$viewCount,"integer")
  statistics_subscribeCount<- checkAndReplaceNull(raw_item$statistics$subscriberCount,"integer")
  statistics_videoCount <- checkAndReplaceNull(raw_item$statistics$videoCount,"integer")
  topicDetails_topicIds <-  checkAndReplaceNull(raw_item$topicDetails$topicIds,"list")
  topicDetails_topicCategories <- checkAndReplaceNull(raw_item$topicDetails$topicCategories,"list")
  
  return(list(id,
              snippet_title,
              snippet_description,
              snippet_country,
              snippet_defaultLanguage,
              contentDetails_relatedPlaylist_likes,
              contentDetails_relatedPlaylist_favourites,
              contentDetails_relatedPlaylist_uploads,
              statistics_viewCount,
              statistics_subscribeCount,
              statistics_videoCount,
              topicDetails_topicIds,
              topicDetails_topicCategories))
}

#channel list() api call with channelID specification
#quota cost: 1
APIgetChannel <- function(channelId){
  url <- paste0("https://youtube.googleapis.com/youtube/v3/channels?part=snippet%2CcontentDetails%2CbrandingSettings%2Cstatistics%2CtopicDetails%2Cid&id=", channelId, "&key=",key)
  url <- URLencode(url)
  print("APIGetChannel")
  print(url)
  res <- GET(url)
  res_data <- content(res)
  return(res_data)
}

#channel list() api call with username specification
#quota cost: 1
APIgetChannelForUsername <- function(username){
  url <- paste0("https://youtube.googleapis.com/youtube/v3/channels?part=snippet%2CcontentDetails%2CbrandingSettings%2Cstatistics%2CtopicDetails%2Cid&forUsername=", username, "&key=",key)
  url <- URLencode(url)
  print("APIgetChannelForUsername")
  print(url)
  res <- GET(url)
  res_data <- content(res)
  return(res_data)
}

#search list() api call with username specification and channel type-of-result limit
#quota cost: 100
APIsearchChannel <- function(username){
  url <- paste0("https://youtube.googleapis.com/youtube/v3/search?part=snippet&maxResults=25&q=", username, "&type=channel&key=",key)
  url <- URLencode(url)
  print("APIsearchChannel")
  print(url)
  res <- GET(url)
  res_data <- content(res)
  return(res_data)
}
