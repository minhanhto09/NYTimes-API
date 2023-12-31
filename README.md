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

1. Create a sample URL that lets us download front-page articles for a given day. This URL will be important for our next task.

2. Develop a function called get_nyt_articles() to access historical New York Times articles for a specific date.

3. Build a user-friendly Shiny app that allows users to choose a year, month, and day. Users can also input their own APIs if they prefer. The app will display a neatly organized list of front-page New York Times headlines for the chosen date. Additionally, users can click on any headline to see more details, including the title, author, first paragraph, an image, and a working link to the full article on nytimes.com.

For detailed instructions on each task, you can refer to the "Description.Rmd" document, and you'll find the code for the Shiny app in the "Shiny.R" file.
