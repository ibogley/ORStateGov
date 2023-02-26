
library(shiny)
library(leaflet)
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
          plotOutput("SenateParty"),
          leafletOutput("SenateDistricts")
        )
      )
    ),
    tabPanel(
      "House",
      sidebarLayout(
        sidebarPanel(
          selectInput("HouseVisualType","Visual",c("Parties","Districts")),
          width = 2
        ),
        mainPanel(
          plotOutput("HouseParty"),
          leafletOutput("HouseDistricts")
        )
      )
    )
  )
)
