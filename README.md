# RYouTubeDashboard
R Shiny App visualizing information and insights about top 100 YouTube channels.

## Index
- [How to use RYouTubeDashboard](#How-to-use-RYouTubeDashboard)
- [Insights overview](#Insights-overview)
- [Dataset representation](#Dataset-representation)
- [Data gathering and manipulation](#Data-gathering-and-manipulation)
- [Files description](#Files-description)
- [Packages](#Packages)

## How to use RYouTubeDashboard

1. Import `shiny` package;
2. Type this command in your RStudio console: `runGitHub("RYouTubeDashboard", "eliroc98", "master")` .

### Insights Panel
- Subscriber/View ratio plot: tweak the slider to select which channel to display;
- Channel Topics plot: choose which topic to include in the pie chart.

### Distribution Plot Panel
- Subscriber Count Distribution plot: choose which subset to display and tweak the slider to select channels having a specific number of subscribers.

### Summary Statistics Panel
- Statistics Table: choose which subset to display, select which variable and statistic to show. Since bootstrapping technique is used, this operation could take some time (even if is is optimized using clusters).

### Dataset Panel
- Dataset Table: choose which subset to display, select which variable to show.

## Insights overview
RYouTubeDashboard displays simple information about the most famous YouTube channels. 
You can get insights highlighting the subscriber/view ratio for each channel and topics characterizing them.
You will notice that the number of views is always much larger than the number of subribers per channel: this is why many YouTubers always ask their viewers to subscribe to their channel.
With respect to the topics characterizing each channel, it is evident that music is one of the most viewed topic, probably because people use YouTueb to listen to music.

To build this section, it has been necessary to use a few R packages: `shiny`, `DT`, `bslib`, `tidyverse` (each of them is described in [Packages](#Packages) section below).

## Dataset representation
It is possible to access the entire dataset and to get a few statistics describing it.
There are three tabs dedicated to (subscriber count) distribution plots, simple statistics and dataset tables. All these features can be tuned thanks to selection operations in sidebars.

To build this section, it has been necessary to use a few R packages: `shiny`, `DT`, `bslib`, `tidyverse`, `parallel` (each of them is described in [Packages](#Packages) section below).

## Data gathering and manipulation
To get the dataset, it is necessary to know which are the 100 most subscribed YouTube channels and their details.
The following procedure cannot be repeated every time the app starts because there are limits in [YouTube Data v3 API](https://developers.google.com/youtube/v3) quotas, thus it is not possible to run the data gathering procedure more than once in a day.
Web scraping techniques are used to get the 100 most subscribed YouTube channels. This step is performed analysing a ranking list in [this](https://socialblade.com/youtube/top/100/mostsubscribed) website.
Extracting information about each item in the ranking list it is possible to know either the channel Id or the username associated with a channel or a keyword referring to a channel. Depending on the information provided, it is necessary to perform three different API calls to [YouTube Data v3 API](https://developers.google.com/youtube/v3):
- [`channel list()`](https://developers.google.com/youtube/v3/docs/channels/list) with channelId specification;
- [`channel list()`](https://developers.google.com/youtube/v3/docs/channels/list) with username specification;
- [`search list()`](https://developers.google.com/youtube/v3/docs/search/list) with keyword specification and channel type-of-result limit (this call is performed when no channel is retrieved by the previous API call).

To be able to perform analysis, it has been necessary to convert the topic list retrieved by the API to additional dummy variables, each of which take value 0 or 1, depending on the precence of a topic in a channel specification.

The packages used to support this procedure are: `httr`, `rvest`, `parallel` (each of them is described in [Packages](#Packages) section below).

## Files description
- [data\dataset.csv](data//dataset.csv) contains data gathering output;
- data\dataset_adjusted.csv contains data manipulation ouput;
- data\topicIds.csv contains a list associating each topic ID to its topic;
- r_files\data_gathering.R contains the code used to perform data gathering (web scraping and API calls);
- r_files\data_gathering_utils.R collects a few user-defined functions used in data_gathering.R;
- r_files\data_manipulation.R contains the code used to perform data manipulation;
- r_files\utils.R collects a few user-defined functions used in app.R;
- app.R contains the code used to run RYouTubeDashboard shiny app.

## Packages
### shiny
[`shiny`](https://shiny.rstudio.com/) is an R package that makes it easy to build interactive web apps straight from R. You can host standalone apps on a webpage or embed them in R Markdown documents or build dashboards. You can also extend your Shiny apps with CSS themes, htmlwidgets, and JavaScript actions.
Reference: https://shiny.rstudio.com/ .
### DT
The R package [`DT`](https://rstudio.github.io/DT/) provides an R interface to the JavaScript library DataTables. R data objects (matrices or data frames) can be displayed as tables on HTML pages, and DataTables provides filtering, pagination, sorting, and many other features in the tables.
Reference: https://rstudio.github.io/DT/ .
### bslib
The [`bslib`](https://rstudio.github.io/bslib/index.html= R package provides tools for customizing Bootstrap themes directly from R, making it much easier to customize the appearance of Shiny apps & R Markdown documents. 
Reference: https://rstudio.github.io/bslib/index.html .
### tidyverse
The [`tidyverse`](https://www.tidyverse.org/= is an opinionated collection of R packages designed for data science. All packages share an underlying design philosophy, grammar, and data structures.
Reference: https://www.tidyverse.org/ .
### parallel
The R [`parallel`](https://subscription.packtpub.com/book/big_data_and_business_intelligence/9781784394004/1/ch01lvl1sec09/the-r-parallel-package) package is now part of the core distribution of R. It includes a number of different mechanisms to enable you to exploit parallelism utilizing the multiple cores in your processor(s) as well as compute the resources distributed across a network as a cluster of machines.
Reference: https://subscription.packtpub.com/book/big_data_and_business_intelligence/9781784394004/1/ch01lvl1sec09/the-r-parallel-package .
### httr
Useful tools for working with HTTP organised by HTTP verbs (GET(), POST(), etc). Configuration functions make it easy to control additional request components (authenticate(),
add_headers() and so on).
Reference: https://cran.r-project.org/web/packages/httr/httr.pdf .
### rvest
Wrappers around the 'xml2' and 'httr' packages to make it easy to download, then manipulate, HTML and XML.
Reference: https://cran.r-project.org/web/packages/rvest/rvest.pdf .
