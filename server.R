

library(shiny)
library(tidyverse)
# Define server logic required to draw a histogram
function(input, output, session) {

    url <- "https://www.oregonlegislature.gov/senate/Pages/SenatorsAll.aspx"
    
    table <- read_html(url) %>%
      html_node(xpath = '//*[@id="{DF544E1D-28E9-40F0-B043-431452D58D01}-{4D9B279B-5391-443D-80C1-16C74D1E19B6}"]') %>%
      html_table(fill = TRUE) %>% .[,2] %>% mutate(MemberContent = gsub("<.*>|\u200B","",MemberContent)) %>%
      mutate(SenatorName = gsub(" $","",gsub("Senator ([A-z \\.]*).*\r.*","\\1",MemberContent)),
             Party = gsub(".*Party([A-Z]{1}[a-z]*).*","\\1",gsub("[^A-z]","",MemberContent)),
             District = as.integer(gsub(".*District([0-9]+)View.*","\\1",gsub("[^[:alnum:]]","",MemberContent))),
             CapitolPhone = gsub(".*Phone([0-9]*)[A-z].*","\\1",gsub("[^[:alnum:]]","",MemberContent)),
             CapitolAddress = gsub(".*CapitolAddress(.*)Email.*","\\1",gsub("[^[:alnum:],]","",MemberContent)),
             Email = gsub(".*Email(.*)Website.*","\\1",gsub("[^[:alnum:].@]","",MemberContent)),
             Website = gsub(".*Website:(.*)$","\\1",gsub("[^[:alnum:]:./]","",MemberContent)),
             MemberContent = NULL) %>%
      .[order(.$District),]
    
    
    output$SenateParty <- renderPlot({
      expand.grid(row = 1:3, column = 1:10) %>% 
      ggplot(aes(x = column, y = row,
                 color = table$Party[order(table$Party)],size = 1)) + 
      geom_point(shape = 15) +
      geom_label(aes(x = column, y = row-.4,size = 1,
                     label = str_wrap(table$SenatorName[order(table$Party)],10))) +
      theme(legend.position = "none",
            axis.text = element_blank(),
            axis.ticks = element_blank(),
            axis.title = element_blank(),
            plot.title = element_text(hjust = .5)) +
      labs(title = "Party Representation: OR Senate") +
      scale_color_manual(values = c("blue","darkgreen","red")) +
      scale_y_continuous(limits = c(0.2,3))
    })
      
}
