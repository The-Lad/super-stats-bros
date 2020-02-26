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

if (file.exists('data/dont_commit/char_stats.rds')) {
  source('load_app_data.R')
} else {
  source('compile_data.R')
}


ui<- dashboardPage(
  #setBackgroundColor("#FFFFFF"),
  dashboardHeader(title = 'SUPER STATS BROS'),
  dashboardSidebar(
    selectInput('xvar_input', label = 'Choose x variable:',
                choices = setdiff(all_plot_vars, 'tier'),
                selected = 'air_speed'),
    selectInput('yvar_input', label = 'Choose y variable:',
                choices = setdiff(all_plot_vars, 'tier'),
                selected = 'fall_speed'),
    prettyCheckbox('img_markers', label = 'Images as markers?', shape = 'curve'),
    prettyCheckbox('tier_boxplot', label = "Group by tier?", shape = 'curve'),
    switchInput(
      inputId = "tier_color_scheme",
      onLabel = 'dumpster \nto glory',
      offLabel = 'boring',
      label = "<i class=\"fa fa-grin-hearts\"></i>"
    )
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
  
  observeEvent(input$tier_boxplot, {
    toggle('tier_color_scheme')
   
    tableProxy %>%
      selectRows('')
  })
  
  
  reactive_dataset <- reactive({
    
    if(input$tier_boxplot){
      tier_stats %>% 
             select(name = tier, yvar = !!paste0(input$yvar_input, '_mean'), yvar_sd = !!paste0(input$yvar_input, '_sd'),
                    xvar = !!paste0(input$xvar_input, '_mean'), xvar_sd = !!paste0(input$xvar_input, '_sd')) %>% 
             arrange(name) %>% 
             mutate(color = if(input$tier_color_scheme) {tier_cols_dg} else {tier_cols_bg}, image = tier_images) %>%
             do(., if(input$img_markers) {mutate(., marker = purrr::map(image, ~ list(symbol = sprintf("url(%s)", .x), width = 32, height = 32)))} else {.}) 
        
        } else {
      char_stats %>%
      select(name = character, image = icon_url_path, color, xvar = input$xvar_input, yvar = input$yvar_input) %>%  
             #group := ifelse(input$tier_boxplot, !!'tier', one_of('you_get_nothing_you_lose'))) %>%
      filter_all(all_vars(!is.na(.))) %>%
      mutate(color = toupper(color)) %>%
      do(., if(input$img_markers) {mutate(., marker = purrr::map(image, ~ list(symbol = sprintf("url(%s)", .x), width = 32, height = 32)))} else {.}) %>% 
      arrange(name)
      }
    
    
  })
  
  main_hc <- reactive({
    hchart(reactive_dataset(), type = 'scatter',
           hcaes(y = yvar, x = xvar, color = color, name = name, image =  image)) %>% 
      hc_legend(enabled = FALSE) %>%
      hc_xAxis(title = list(text = input$xvar_input))%>%
      hc_yAxis(title = list(text = input$yvar_input))%>%
      hc_plotOptions(series = list(allowPointSelect= FALSE)) %>%
      hc_chart(zoomType = 'xy') %>% 
      hc_add_event_point(event = "click") %>%
      #hc_add_event_point(event = "unselect") %>%
      hc_add_series(data = if (is.null(input$main_datatable_rows_selected) | input$tier_boxplot) {NULL}
                    else {select(reactive_dataset()[input$main_datatable_rows_selected, ], x= xvar, y = yvar, color, name, image)},
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
    datatable(reactive_dataset() %>% select(name, !!input$xvar_input := 'xvar', !!input$yvar_input := 'yvar'), selection = "single", rownames = FALSE, options = list(dom = 'tf'))
  }, server = TRUE)
  
  tableProxy <-  dataTableProxy("main_datatable")
  
  # observeEvent(input$main_plot_unselect, {
  # browser()
  #   })
  
  observeEvent(input$main_plot_click, {
    if (input$main_plot_click$series == 'Series 1') {
      charId = which(reactive_dataset()$name == input$main_plot_click$name)
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




