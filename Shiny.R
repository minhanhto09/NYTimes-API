library(shiny)
library(tidyverse)
library(shinythemes)

# The following line will load all of your R code from the qmd
# this will make your get_nyt_articles function available to your
# shiny app.

source(
  knitr::purl("Description.Rmd", output=tempfile(), quiet=TRUE)
)

shinyApp(
  ui = fluidPage(
    theme = shinytheme("cerulean"),
    titlePanel(tags$b("NYT Articles Search")),
    sidebarLayout(
      sidebarPanel(
        dateInput("date", "Select Date", value = as.Date("2020-09-01")),
        textInput("api_key", "Enter Your API Key", value = "YuqX3BoGbcqzNokjsTgDf4zl1Idym9o8"),
        actionButton("get_headlines", "Get Headlines")
      ),
      mainPanel(
        fluidRow(
          column(width = 12,
                 uiOutput("links")
          )
        )
      )
    )
  ),
  
  server = function(input, output, session) {
    state <- reactiveValues(
      headlines = NULL,  # Initialize headlines outside of observe
      modals = list()    # Create a list to store modals
    )
    
    observeEvent(input$get_headlines, {
      selected_date <- input$date
      api_key <- input$api_key
      
      headlines <- get_nyt_articles(
        year(selected_date),
        month(selected_date),
        day(selected_date),
        api_key
      )
      
      if (!is.null(headlines) && nrow(headlines) > 0) {
        output$links <- renderUI({
          ui_elems <- purrr::map(
            seq_len(nrow(headlines)), 
            function(i) {
              fluidRow(
                column(
                  width = 12,
                  style = "margin-bottom: 10px;",  # Add spacing between headlines
                  actionLink(
                    paste0("link", i),
                    headlines[i, "headline.main"]
                  )
                )
              )
            }
          )
          fluidPage(ui_elems)
        })
        
        # Create modals dynamically and store them in the modals list
        # Create modals dynamically and store them in the modals list
        for (i in seq_len(nrow(headlines))) {
          local({
            idx <- i
            observeEvent(input[[paste0("link", idx)]], {
              # Check if multimedia data is available for the current headline
              if (!is.null(headlines$multimedia[[idx]]) && length(headlines$multimedia[[idx]]) > 0) {
                # Extract the first image URL for the headline
                image_url <- paste0("https://static01.nyt.com/", headlines$multimedia[[idx]][[6]][[1]], "?quality=75&auto=webp")
              } else {
                # Handle the case where multimedia data is not available
                image_url <- NULL
              }
              
              modal <- modalDialog(
                title = headlines[idx, "headline.main"],
                HTML(paste0(headlines[idx, "byline.original"], "</p>")),
                HTML(paste0(headlines[idx, "lead_paragraph"], "</p>")),
                if (!is.null(image_url)) {
                  img(src = image_url, width = "100%")
                },
                easyClose = TRUE,
                footer = tagList(
                  tags$a("Read Full Article", href = headlines[idx, "web_url"], target = "_blank")
                )
              )
              showModal(modal)
              state$modals[[paste0("link", idx)]] <- modal
            })
          })
        }
        
      } else {
        output$links <- renderUI({
          fluidRow(
            column(
              width = 12,
              p("Error: Unable to retrieve headlines. Please check your API key and try again.")
            )
          )
        })
      }
    })
  }
)
