
library(shiny)
library(rvest)

# Define UI for application that draws a histogram
fluidPage(
  tabsetPanel(
    tabPanel(
      "Senate",
      sidebarLayout(
        sidebarPanel(
          selectInput("SenateVisualType","Visual",c("Parties","Districts")),
          width = 2
        ),
        mainPanel(
          plotOutput("SenateParty")
        )
      )
    )
  )
)
