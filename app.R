#install.packages(c("shiny","DT","bslib","tidyverse","httr","rvest"))

#setwd("C:/Users/lizzy/Desktop/Universita/coding for data science and data management/R/project/YouTubeChannels")
library(shiny)
library('tidyverse')
library(DT)
library(bslib)
source("r_files/utils.R")

#import data: data acquisition is performed once because of the YouTube API limit quota
data <- read.csv(file = 'data/dataset_adjusted.csv')

max_subs <- max(data$statistics_subscriberCount, na.rm=T)

ui <- fluidPage(
    theme = bs_theme(version = 4, bootswatch = "minty"),
    titlePanel("Top 100 Youtube Channels"),
    
    sidebarLayout(
        sidebarPanel(
        #Distribution Plot Panel: sidebar
        conditionalPanel(
            condition="input.tabset==1",
            h3("Select Data"),
            radioButtons("radio_type",
                         h4("Type of dataset"),
                         choices = list("Entire" = 1, 
                                        "Only Youtube Channels" = 2, 
                                        "Only Youtube Playlists" = 3),
                         selected = 1),
            sliderInput("slider_numberSubs",
                        h4("Number of Subscribers"),
                        min = 0, max = max_subs, value = c(0, max_subs)),
        ),
        #Summary Statistics Panel: sidebar
        conditionalPanel(
            condition="input.tabset==2",
            h3("Select Data"),
            radioButtons("radio_type_2",
                         h4("Type of dataset"),
                         choices = list("Entire" = 1, 
                                        "Only Youtube Channels" = 2, 
                                        "Only Youtube Playlists" = 3),
                         selected = 1),
            h3("Select Statistics"),
            checkboxGroupInput("stats_vars", "Variables:",
                               c("statistics_viewCount","statistics_subscriberCount","statistics_videoCount"), selected = c("statistics_viewCount","statistics_subscriberCount","statistics_videoCount")),
            checkboxGroupInput("stats_to_show","Statistics:",
                               c("mean","median","variance"),
                               selected=c("mean")),
        ),
        #Dataset Panel: sidebar
        conditionalPanel(
            condition="input.tabset==3",
            h3("Select variables"),
            radioButtons("radio_type_3",
                         h4("Type of dataset"),
                         choices = list("Entire" = 1, 
                                        "Only Youtube Channels" = 2, 
                                        "Only Youtube Playlists" = 3),
                         selected = 1),
            checkboxGroupInput("show_vars", "Variables to show:",
                               names(data), selected = c("snippet_title","statistics_viewCount","statistics_subscriberCount","statistics_videoCount")),
        ),
        #Insights Panel: sidebar
        conditionalPanel(
            condition="input.tabset==4",
            h3("Subscriber/View ratio"),
            sliderInput("slider_channels",
                        h4("Channels to display"),
                        min = 1, max = 100, value = c(1, 5)),
            br(),
            br(),
            br(),
            br(),
            br(),
            br(),
            h3("Channels Topics"),
            checkboxGroupInput("topics", "Topics:",
                               names(data[15:ncol(data)]), selected = c("Music","Gaming","Movies","Sports","Entertainment")),
        )),

        mainPanel(
            tabsetPanel(id = "tabset",
                        type = "tabs",
                        tabPanel("Insights", 
                                 plotOutput("insights_plot"),
                                 plotOutput("topic_pie"),
                                 value=4),
                        tabPanel("Distribution Plot", 
                                 plotOutput("distribution_plot"),
                                 value=1),
                        tabPanel("Summary Statistics",
                                 DT::dataTableOutput("summary_stats"),
                                 p("Confidence Intervals are computed using the bootstrapping technique."),
                                 value=2),
                        tabPanel("Dataset",
                                 DT::dataTableOutput("data_table"),
                                 value=3)
            )
        )
    )
)


server <- function(input, output) {
    #Data for Subscriber Count Distribution plot
    data_to_show <- reactive({
        switch(input$radio_type, 
               "1"={to_show <- data},
               "2"={to_show <- data[data$youtube_playlist==0,]},
               "3"={to_show <- data[data$youtube_playlist==1,]})
        to_show <- to_show[to_show$statistics_subscriberCount>=input$slider_numberSubs[1] & to_show$statistics_subscriberCount<=input$slider_numberSubs[2],]
        return(to_show)
       })
    
    #Data for Dataset Table
    data_to_show_variables <- reactive({
        switch(input$radio_type_3, 
               "1"={to_show <- data},
               "2"={to_show <- data[data$youtube_playlist==0,]},
               "3"={to_show <- data[data$youtube_playlist==1,]})
        to_show <- to_show[,input$show_vars]
    })
    
    #Data for Statistics Table
    statistics_to_show <- reactive({
        switch(input$radio_type_2, 
               "1"={to_show <- data},
               "2"={to_show <- data[data$youtube_playlist==0,]},
               "3"={to_show <- data[data$youtube_playlist==1,]})
        progress <- shiny::Progress$new()
        on.exit(progress$close())
        progress$set(message = "Making statistics", value = 0)
        table_sum <- summary_stats_table(to_show,input$stats_vars,input$stats_to_show,progress)
        return(table_sum)
    })
    
    #Subscriber Count Distribution plot
    output$distribution_plot<-renderPlot({
        dt <- data_to_show()
        ggplot(dt, aes(x=statistics_subscriberCount))+
            geom_histogram(aes(y=..density..),
                           colour="black", fill="white") +
            geom_vline(aes(xintercept=mean(statistics_subscriberCount, na.rm=T)),  
                       color="red", linetype="dashed", size=1)+
            geom_density(alpha=.2, fill="#FF6666")+
            labs(title="Subscriber Count Distribution", x="Subscriber count", y="Density")+
            theme(plot.title=element_text(size=20,face="bold"))
    })
    
    #Dataset Table
    output$data_table = DT::renderDataTable({
        if(length(input$show_vars)!=0){
            data_to_show_variables()
        }
    })
    
    #Statistics Table
    output$summary_stats = DT::renderDataTable({
        if(length(input$stats_vars)!=0 & length(input$stats_to_show)!=0){
            statistics_to_show()
        }
    })
    
    #Subscriber/View ratio plot
    output$insights_plot = renderPlot({
        d<-data[data$youtube_playlist==0 & data$id!="UCRv76wLBC73jiP7LX4C3l8Q",]
        d<-d[input$slider_channels[1]:input$slider_channels[2],]
        df<-data.frame(channel<-rep(d$snippet_title,2), count=c(d$statistics_subscriberCount,d$statistics_viewCount),count_type=c(rep("subscriberCount",nrow(d)),rep("viewCount",nrow(d))))
        require(scales)
        ggplot(df, 
               aes(x = channel, fill=count_type,y=count)) +
            theme(axis.text.x = element_text(angle = 90))+
            geom_col(position = position_dodge())+
            scale_y_continuous(trans = 'log2',
                               breaks = trans_breaks("log2", function(x) 2^x),
                               labels = trans_format("log2", math_format(2^.x)))+
            labs(title="Subscriber/View Ratio")+ 
            theme(plot.title=element_text(size=20,face="bold"))
    })
    
    #Channel Topics plot
    output$topic_pie = renderPlot({
        if(length(input$topics)!=0){
            d<-data %>%
                select(input$topics)
            print(names(d))
            df_sums <- data.frame(topic="Music", count=sum(data$Music))
            for(i in 1:ncol(d)){
                df_sums <- rbind(df_sums,c(names(d)[i],sum(d[names(d)[i]])))
            }
            
            df_sums<-df_sums[-1,]
            
            ggplot(df_sums, aes(x = "", y = count, fill = topic)) +
                geom_bar(width = 1, stat = "identity") +
                coord_polar("y", start = 0)+
                theme_void()+
                labs(title="Channels Topics")+ 
                theme(plot.title=element_text(size=20,face="bold"))
        }
    })
    
        
}

# Run the application 
shinyApp(ui = ui, server = server)
