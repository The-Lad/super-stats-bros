###################################
## SUPER STATS BROS v0.01       ##
## Author: Nicholas Meuli        ##
###################################
library(shiny)
library(shinyWidgets)
library(shinyjs)
library(shinydashboard)
library(highcharter)
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
                choices = all_plot_vars,
                selected = 'fall_speed')
  ), 
  dashboardBody(
    #titlePanel('SUPER STATS BROS'),
    box(
      highchartOutput('main_plot'),
      background = "green",
      width = 12
    )
  ),
  shinyjs::useShinyjs()
)

server <- function(input, output, session) {
  
  observeEvent(input$xvar_input, {
    print('new xvar')
  })
  
  reactive_dataset <- reactive({
    char_stats %>%
      select(character, icon_url_path, color, xvar = input$xvar_input, yvar = input$yvar_input) %>%
      filter_all(all_vars(!is.na(.))) %>%
      mutate(color = toupper(color))
    
  })
  
  
  output$main_plot <- renderHighchart({
    # browser()
      hchart(reactive_dataset(), hcaes(y = yvar, x = xvar, color = color, name = character, image =  icon_url_path), type = 'scatter') %>% 
      hc_tooltip(useHTML = TRUE, 
                 #pointFormat = '<span style="color:{point.color}">Fall speed: </span>: {point.y:,.0f}<br/>',
                 #headerFormat = '<span style="font-size: 10px">{series.name}</span><br/>',
                 formatter= JS("function() {return (this.point.name + '<span style=\"color: this.point.color\"></br>y: <b>' + this.point.y + '</b> </br> x: <b>' +
   this.point.x + '</b></span></br><img src=\"'+ this.point.image + '\"width=\"48\" height=\"48\"/></br>');}")) %>% 
      hc_legend(enabled = FALSE) %>%
      hc_xAxis(title = list(text = input$xvar_input))%>%
      hc_yAxis(title = list(text = input$yvar_input))%>%
      hc_plotOptions(series = list(states = list(hover = list(enabled = FALSE)), dataGrouping = list(enabled = FALSE)))%>% 
      #hc_chart(events = list(
      #    load= JS(js_searchbox))) %>%
      hc_add_theme(hc_theme_chalk()) 
    
  })
}


# Run the application 
shinyApp(ui = ui, server = server)




