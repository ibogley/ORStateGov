library(shiny)
library(tidyverse)
library(rvest)
library(leaflet)

function(input, output, session) {

    urlSenate <- "https://www.oregonlegislature.gov/senate/Pages/SenatorsAll.aspx"
    urlHouse <- "https://www.oregonlegislature.gov/house/Pages/RepresentativesAll.aspx"
    
    tableSenate <- read_html(urlSenate) %>%
      html_node(xpath = '//*[@id="{DF544E1D-28E9-40F0-B043-431452D58D01}-{4D9B279B-5391-443D-80C1-16C74D1E19B6}"]') %>%
      html_table(fill = TRUE) %>% .[,2] %>% mutate(MemberContent = gsub("<.*>|\u200B","",MemberContent)) %>%
      mutate(SenatorName = gsub(" $","",gsub("Senator ([A-z \\.]*).*\r.*","\\1",MemberContent)),
             Party = gsub(".*Party([A-Z]{1}[a-z]*).*","\\1",gsub("[^A-z]","",MemberContent)),
             District = as.integer(gsub(".*District([0-9]+)View.*","\\1",gsub("[^[:alnum:]]","",MemberContent))),
             CapitolPhone = gsub(".*Phone([0-9]*)[A-z].*","\\1",gsub("[^[:alnum:]]","",MemberContent)),
             CapitolAddress = gsub(".*CapitolAddress(.*)Email.*","\\1",gsub("[^[:alnum:],]","",MemberContent)),
             Email = gsub(".*Email(.*)Website.*","\\1",gsub("[^[:alnum:].@]","",MemberContent)),
             Website = gsub(".*Website:(.*)$","\\1",gsub("[^[:alnum:]:./]","",MemberContent)),
             PartyColor = ifelse(Party =="Republican","red",ifelse(Party == "Democratic","blue","purple")),
             MemberContent = NULL) %>%
      .[order(.$District),]
    
    tableHouse <- read_html(urlHouse) %>%
      html_node(xpath = '//*[@id="{8F234EA9-D81F-4CDB-9B30-97029307D60E}-{D1FD634E-DD35-450D-906D-F3215ECE17DC}"]') %>%
      html_table(fill = TRUE) %>% .[,2] %>% 
      mutate(MemberContent = gsub("<.*>|\u200B","",MemberContact),MemberContact = NULL) %>%
      mutate(RepresentativeName = gsub(" *$","",gsub("Representative ([A-z -\\.]*).*\r.*","\\1",MemberContent)),
             Party = gsub(".*Party([A-Z]{1}[a-z]*).*","\\1",gsub("[^A-z]","",MemberContent)),
             District = as.integer(gsub(".*District([0-9]+)View.*","\\1",gsub("[^[:alnum:]]","",MemberContent))),
             CapitolPhone = gsub(".*Phone([0-9]*)[A-z].*","\\1",gsub("[^[:alnum:]]","",MemberContent)),
             CapitolAddress = gsub(".*CapitolAddress(.*)Email.*","\\1",gsub("[^[:alnum:],]","",MemberContent)),
             Email = gsub(".*Email(.*)Website.*","\\1",gsub("[^[:alnum:].@]","",MemberContent)),
             Website = gsub(".*Website:(.*)$","\\1",gsub("[^[:alnum:]:./]","",MemberContent)),
             PartyColor = ifelse(Party =="Republican","red",ifelse(Party == "Democratic","blue","purple")),
             MemberContent = NULL) %>%
      .[order(.$District),]
    
    output$SenateParty <- renderPlot({
      expand.grid(row = 1:3, column = 1:10) %>% 
      ggplot(aes(x = column, y = row,
                 color = tableSenate$PartyColor[order(tableSenate$Party)],size = 1)) + 
      geom_point(shape = 15) +
      geom_label(aes(x = column, y = row-.4,size = 1,
                     label = str_wrap(tableSenate$SenatorName[order(tableSenate$Party)],10))) +
      theme(legend.position = "none",
            axis.text = element_blank(),
            axis.ticks = element_blank(),
            axis.title = element_blank(),
            plot.title = element_text(hjust = .5)) +
      labs(title = "Party Representation: OR Senate") +
      scale_color_identity() +
      scale_y_continuous(limits = c(0.2,3))
    })
    
    output$HouseParty <- renderPlot({
      expand.grid(row = 1:6, column = 1:10) %>%
        ggplot(aes(x = column, y = row,
                   color = tableHouse$PartyColor[order(tableHouse$Party)],size = 1)) + 
        geom_point(shape = 15) +
        geom_label(aes(x = column, y = row-.4,size = 1,
                       label = str_wrap(tableHouse$RepresentativeName[order(tableHouse$Party)],10))) +
        theme(legend.position = "none",
              axis.text = element_blank(),
              axis.ticks = element_blank(),
              axis.title = element_blank(),
              plot.title = element_text(hjust = .5)) +
        labs(title = "Party Representation: OR House of Representatives") +
        scale_color_identity() +
        scale_y_continuous()
    })
    
    output$SenateDistricts <- renderPlot({
      senatesf <- read_sf("Senate SB 882") %>% st_transform(crs = st_crs("WGS84")) %>%
        rename(District = DISTRICT) %>% left_join(tableSenate) %>%
        mutate(tooltip = paste("District:",District,"<br>Senator:",SenatorName))
      
      leaflet(senatesf) %>% addTiles() %>% addPolygons(color = ~PartyColor,popup = ~tooltip)
    })
    
    output$HouseDistricts <- renderLeaflet({
      housesf <- read_sf("House SB 882") %>% st_transform(crs = st_crs("WGS84")) %>%
        rename(District = DISTRICT) %>% left_join(tableHouse) %>%
        mutate(tooltip = paste("District:",District,"<br>Representative:",RepresentativeName))
      
      leaflet(housesf) %>% addTiles() %>% addPolygons(color = ~PartyColor,popup = ~tooltip)
      
    })
}
