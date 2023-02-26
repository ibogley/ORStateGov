
library(shiny)
library(leaflet)
fluidPage(
  titlePanel("Oregon Local Government"),
  tabsetPanel(
    tabPanel(
      "Legislature",
      sidebarLayout(
        sidebarPanel(
          selectInput("Body","Body",c("Senate","House of Representatives")),
          selectInput("VisualSelector","Visual",c("Party Representation","District Map")),
          width = 2
        ),
        mainPanel(
          uiOutput("LegislatureVisual")
        )
      )
    ),
    tabPanel(
      "Governor"
    )
  )
)
