
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
      "State Law",
      a("Link to current OR State Law",href = "https://www.oregonlegislature.gov/bills_laws/pages/ors.aspx")
    ),
    tabPanel(
      "Governor/Executive Agencies",
      uiOutput("AgenciesBoardsCommissions")
    )
  )
)
