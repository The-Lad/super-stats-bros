###################################
## SUPER STATS BROS v0.01       ##
## Author: Nicholas Meuli        ##
###################################
library(shiny)
library(shinyWidgets)
library(shinyjs)
library(shinydashboard)
library(highcharter)
library(DT)
library(dplyr)
#source("imageBoxFunctions.R", local = TRUE)

if (file.exists('data/char_stats.rds')) {
  source('load_app_data.R')
} else {
  source('compile_data.R')
}


ui<- dashboardPage(
  #setBackgroundColor("#FFFFFF"),
  dashboardHeader(title = 'SUPER STATS BROS'),
  dashboardSidebar(
    selectInput('xvar_input', label = 'Choose x variable:',
                choices = all_plot_vars,
                selected = 'air_speed'),
    selectInput('yvar_input', label = 'Choose y variable:',
                choices = setdiff(all_plot_vars, 'tier'),
                selected = 'fall_speed'),
    prettyCheckbox('tier_boxplot', label = "Group by tier?", shape = 'curve')
  ), 
  dashboardBody(
    #titlePanel('SUPER STATS BROS'),
    box(
      highchartOutput('main_plot'),
      background = "green",
      width = 12
    ),
    hr(),
    box(
      dataTableOutput('main_datatable'),
      width = 12
    )
  ),
  shinyjs::useShinyjs()
)

server <- function(input, output, session) {
  
  observeEvent(input$xvar_input, {
    #
  })
  
  
  reactive_dataset <- reactive({
    # browser()
    char_stats %>%
      select(character, icon_url_path, color, xvar = input$xvar_input, yvar = input$yvar_input) %>%
      filter_all(all_vars(!is.na(.))) %>%
      mutate(color = toupper(color)) %>%
      #do(., if(!is.null(char_selected())) {mutate(., color = ifelse())} else {.}) %>% 
      arrange(character)
    
    
  })
  
  main_hc <- reactive({
    #browser()
    hchart(reactive_dataset(), type = 'scatter', hcaes(y = yvar, x = xvar, color = color, name = character, image =  icon_url_path)) %>% 
      hc_legend(enabled = FALSE) %>%
      hc_xAxis(title = list(text = input$xvar_input))%>%
      hc_yAxis(title = list(text = input$yvar_input))%>%
      hc_plotOptions(series = list(allowPointSelect= TRUE)) %>% 
      hc_add_event_point(event = "click") %>% 
      #hc_add_event_point(event = "mouseOut") %>% 
      hc_add_series(data = if (is.null(input$main_datatable_rows_selected)) {NULL} 
                    else {select(reactive_dataset()[input$main_datatable_rows_selected, ], x= xvar, y = yvar, color = color, name = character, image = icon_url_path)},  
                    type = 'scatter', marker = list(radius = 30, lineColor = '#32CD32', lineWidth = 5)) %>% 
      hc_tooltip(useHTML = TRUE, 
                 formatter= JS("function() {return (this.point.name + '<span style=\"color: this.point.color\"></br>y: <b>' + this.point.y + '</b> </br> x: <b>' +
   this.point.x + '</b></span></br><img src=\"'+ this.point.image + '\"width=\"48\" height=\"48\"/></br>');}")) %>% 
      hc_add_theme(hc_theme_chalk()) 
    
    #slice(reactive_dataset(), 0)
  })
  
  output$main_plot <- renderHighchart({
    # browser()
    main_hc()
  })
  
  output$main_datatable <- renderDataTable({
    datatable(reactive_dataset() %>% select(character, !!input$xvar_input := 'xvar', !!input$yvar_input := 'yvar'), selection = "single", rownames = FALSE, options = list(dom = 'tf'))
  }, server = TRUE)
  
  tableProxy <-  dataTableProxy("main_datatable")
  
  observeEvent(input$main_plot_click, {
    if (input$main_plot_click$series == 'Series 1') {
      charId = which(reactive_dataset()$character == input$main_plot_click$name)
      tableProxy %>% 
        selectRows(charId) %>%
        selectPage( (charId-1) %/% number_of_rows_dt + 1)
    } else {
      #browser()
      tableProxy %>%
        selectRows('')
    }
  })
  
  # observeEvent(input$main_plot_mouseOut, {
  #   browser()
  #   tableProxy 
  # })
}


# Run the application 
shinyApp(ui = ui, server = server)




