library(shiny)
library('tidyverse')

#import data: data acquisition is performed once because of the YouTube API limit quota
data <- read.csv(file = 'data/dataset_adjusted.csv')

max_subs <- max(data$statistics_subscriberCount, na.rm=T)

ui <- fluidPage(
    titlePanel("Top 100 Youtube Channels"),
    
    sidebarLayout(
        sidebarPanel(
            h3("Select Input Data"),
            radioButtons("radio_type",
                         h4("Type of dataset"),
                         choices = list("Entire" = 1, 
                                        "Only Youtube Channels" = 2, 
                                        "Only Youtube Playlists" = 3),
                         selected = 1),
            sliderInput("slider_numberSubs",
                        h4("Number of Subscribers"),
                        min = 0, max = max_subs, value = c(25, 75)),
        ),

        mainPanel(
            tabsetPanel(type = "tabs",
                        tabPanel("Distribution Plot", plotOutput("distribution_plot")),
                        tabPanel("Summary", verbatimTextOutput("summary")),
                        tabPanel("Table", tableOutput("table"))
            )
        )
    )
    
)

server <- function(input, output) {
    data_to_show <- reactive({
        print(input$radio_type)
        switch(input$radio_type, 
               "1"={to_show <- data},
               "2"={to_show <- data[data$youtube_playlist==0,]},
               "3"={to_show <- data[data$youtube_playlist==1,]})
        print(to_show)
        return(to_show)
       })
    output$distribution_plot<-renderPlot({
        dt <- data_to_show()
        ggplot(dt, aes(x=statistics_subscriberCount))+
            geom_histogram(aes(y=..density..),
                           colour="black", fill="white") +
            geom_vline(aes(xintercept=mean(statistics_subscriberCount, na.rm=T)),  
                       color="red", linetype="dashed", size=1)+
            geom_density(alpha=.2, fill="#FF6666")+
            labs(title="Subscribers", x="Subscriber count", y="Density")
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
