# NYTimes-API

---
title: "NY Times API"
subtitle: "Article Search Shiny App"
author: Minh Anh To
format: 
  html:
    self-contained: true
---

Before you start be sure to read through *all* of the rules and instructions in the `README.md`.


<br/>

### Setup

```{r setup, include=FALSE}
library(tidyverse)
```
-----

### New York Times API

The NY Times provides useful and interesting [APIs](https://developer.nytimes.com/) for accessing their vast archive of articles and editorials spanning over 150 years. For this project, we'll focus on using the [Article Search API](https://developer.nytimes.com/docs/articlesearch-product/1/overview) to gather metadata about NY Times articles throughout its history.

To use any of the NY Times APIs, you must first register with the NY Times [here](https://developer.nytimes.com/accounts/create). Once you've created and verified your account, you can create an App (found in the menu under your email address) and enable access to the Article Search API. During this process, you'll receive an API key to authenticate your requests when using the API. Your API key allows up to 10 requests per minute and 4000 requests per day. While you're unlikely to reach the daily limit, it's important to note that the per-minute limit is relatively easy to hit. To avoid hitting this limit, you may need to implement a delay of approximately 6 seconds between API calls if you need to make more than 10 calls in a minute.

In this project, we'll follow these steps:

    Create a sample URL that lets us download front-page articles for a given day. This URL will be important for our next task.

    Develop a function called get_nyt_articles() to access historical New York Times articles for a specific date.

    Build a user-friendly Shiny app that allows users to choose a year, month, and day. Users can also input their own APIs if they prefer. The app will display a neatly organized list of front-page New York Times headlines for the chosen date. Additionally, users can click on any headline to see more details, including the title, author, first paragraph, an image, and a working link to the full article on nytimes.com.

For detailed instructions on each task, you can refer to the "Description.Rmd" document, and you'll find the code for the Shiny app in the "Shiny.R" file.

-----

### Task 1 - Understanding the NY Times Article Search API

```
https://api.nytimes.com/svc/search/v2/articlesearch.json
?api-key=YuqX3BoGbcqzNokjsTgDf4zl1Idym9o8
&q=
&begin_date=20140929
&end_date=20140929
&fl=web_url,headline,pub_date,print_page,print_section
&fq=document_type:("article") AND print_page:1 AND print_section:"A"
&facet=false
```

* `begin_date=` Specifies the start date for filtering (September 29, 2014).

* `end_date=` Specifies the end date for filtering (September 29, 2014).

* `fl=` Specifies the fields to be included in the response (web URL, headline, publication date, print page, and print section).

* `fq=` Applies a filter query to include only articles of type "article"

* `facet=` Disabled (set to `false`) 
 
-----   

### Task 2 - Getting data from the API

```{r}
library(httr)
library(jsonlite)
library(dplyr)

get_nyt_articles <- function(year, month, day, api_key) {
  
  # Check input values for sanity
  if (!is.numeric(year) || !is.numeric(month) || !is.numeric(day) || !is.character(api_key) ||
      length(year) != 1 || length(month) != 1 || length(day) != 1 || length(api_key) != 1 ||
      year < 1900 || year > 2100 || month < 1 || month > 12 || day < 1 || day > 31) {
    stop("Invalid input values. Please provide valid year, month, day, and API key.")
  }
  
  # Initialize variables
  base_url <- "https://api.nytimes.com/svc/search/v2/articlesearch.json"
  page <- 1
  all_results <- list()
  
  repeat {
    # Create the date string in YYYYMMDD format
    date_str <- sprintf("%04d%02d%02d", year, month, day)
    
    # Build the request URL
    request_url <- paste0(base_url, "?api-key=", api_key,
                          "&begin_date=", date_str,
                          "&end_date=", date_str,
                          "&fl=headline,byline,web_url,lead_paragraph,source,multimedia",
                          "&fq=", URLencode('document_type:("article") AND print_page:1 AND print_section:"A"'),
                          "&legacy=true")
    
    # Make the API request
    response <- GET(request_url)
    
    # Check if the request was successful
    if (status_code(response) != 200) {
      warning("API request failed with status code: ", status_code(response))
      break
    }
    if (status_code(response) == 429) {
      warning("API rate limit exceeded. Retrying after a delay of 10 seconds.")
      Sys.sleep(10)  # Sleep for 10 seconds (adjust as needed)
      next  # Retry the request
    }
    
    # Parse the JSON response
    result <- fromJSON(content(response, "text", encoding = "UTF-8"), flatten = TRUE)
    
    # Check if there are any results
    if (result$response$meta$hits == 0) {
      break  # No results found, exit the loop
    }
    
    # Add the results to the list
    all_results[[page]] <- result$response$docs |> 
      select(headline.main, byline.original, web_url, lead_paragraph, multimedia)
    
    # Check if there are more pages of results
    if (result$response$meta$hits <= page * 10) {
      break  # All results retrieved
    }
    
    # Increment the page counter
    page <- page + 1
    
    # Sleep to avoid exceeding the rate limit
    Sys.sleep(10)  # Sleep for 10 seconds between requests to stay within 10 requests per minute
  }
  
  # Combine all results into a single data frame
  if (length(all_results) > 0) {
    articles <- do.call(rbind, all_results)
    return(articles)
  } else {
    message("No articles found for the specified date and criteria.")
    return(NA)
  }
}

# Show sample output for your function
articles_birthday <- get_nyt_articles(2014, 09, 29, "YuqX3BoGbcqzNokjsTgDf4zl1Idym9o8")
```

<!-- Include your brief write up below -->

The provided R code defines a function called `get_nyt_articles` that retrieves articles from the New York Times Article Search API. It checks the input values for validity, initializes variables, and enters a loop to make API requests for articles. Within the loop, it constructs a request URL, checks response status, and parses JSON responses. It selects specific fields like `headline.main`, `byline.original`, `web_url`, `lead_paragraph`, and `multimedia` from the API responses and adds them to a list. After retrieving all articles, it combines them into a data frame named articles. If no articles are found, it displays a message and returns NA.

To use the function, we can specify a date and API key as arguments, like in the example `articles_birthday`. This function simplifies the process of fetching New York Times articles for analysis or further processing based on your chosen date and criteria.

-----

### Task 3 - Shiny Front End

<!-- Shiny App should be implemented in midterm2.R -->

<!-- Include your brief write up below -->

This Shiny app is designed to allow users to search for New York Times (NYT) articles by specifying a date and providing an API key. The app provides a user interface (UI) and server logic to interact with the NYT API and display article headlines along with links to view the full articles.

Shiny App Structure:

The UI for this Shiny app is created with a "cerulean" theme and includes a title panel labeled "NYT Articles Search." It consists of a sidebarLayout with two panels: a `sidebarPanel` containing `dateInput` for date selection, `textInput` for entering an API key, and an `actionButton` to fetch headlines. The `mainPanel` uses a `fluidRow` to dynamically display article headlines generated using `uiOutput("links")`.

The server logic of this Shiny app manages user interactions and data retrieval by utilizing `reactiveValues` to maintain state, including headlines (initialized as NULL) and modals (a list for storing modal dialogs). An `observeEvent` is set up to respond to the "Get Headlines" button click (`input$get_headlines`). It retrieves the selected date and API key from the input fields and calls the `get_nyt_articles` function to fetch NYT articles based on the provided date and API key. When headlines are successfully retrieved and not empty, the `observeEvent` dynamically generates UI elements for each headline using `renderUI`, presenting each headline as an action link. Additionally, modal dialogs are dynamically created for each headline, triggered by `observeEvent`. When users click on a headline link, a modal dialog is triggered, presenting a comprehensive view of the article's details. This includes the headline, author byline, the initial paragraph, a thumbnail image, and a direct link to the full article. It's important to note that to ensure the accessibility and availability of images, we utilize a consistent image URL format with the prefix "https://static01.nyt.com" and the suffix "?quality=75&auto=webp" instead of the original URL from the multimedia column. These modal dialogs are stored in the `modals` list. If no headlines are retrieved or an error occurs during the process, an error message is displayed to the user.

Overall, this Shiny app allows users to select a date, provide an API key, and retrieve NYT article headlines for that date. Users can then click on a headline to view additional details in a modal dialog and access the full article.
