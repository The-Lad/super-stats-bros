library(highcharter)
library(dplyr)
char_stats = readRDS('data/char_stats.rds')


hchart(char_stats, hcaes(y = `MAX AIR SPEED VALUE`, x = `MAX FALL SPEED`,  name =CHARACTER, group =  `ICON URL PATH`), color = '#000000', type = 'scatter') %>% 
  hc_tooltip(useHTML = TRUE, 
             #pointFormat = '<span style="color:{point.color}">Fall speed: </span>: {point.y:,.0f}<br/>',
             #headerFormat = '<span style="font-size: 10px">{series.name}</span><br/>',
             formatter= JS("function() {return (this.point.name + '</br>y-var:<b>' + this.point.y + '</b> </br> x-var:<b>' +
   this.point.x + '</b></br><img src=\"'+ this.series.name + '\"width=\"48\" height=\"48\"/></br>');}")) %>% 
  hc_legend(enabled = FALSE)

hchart(char_stats, hcaes(y = `USAGE`, x = `WIN RATIO`,  name =CHARACTER, group =  `ICON URL PATH`), color = '#000000', type = 'scatter') %>% 
  hc_tooltip(useHTML = TRUE, 
             #pointFormat = '<span style="color:{point.color}">Fall speed: </span>: {point.y:,.0f}<br/>',
             #headerFormat = '<span style="font-size: 10px">{series.name}</span><br/>',
             formatter= JS("function() {return (this.point.name + '</br>y-var:<b>' + this.point.y + '</b> </br> x-var:<b>' +
   this.point.x + '</b></br><img src=\"'+ this.series.name + '\"width=\"48\" height=\"48\"/></br>');}")) %>% 
  hc_legend(enabled = FALSE)

#  highchart() %>% 
#    hc_add_series(type = 'scatter', data = if (input$tier_boxplot) { NULL} else {select(reactive_dataset(), x= xvar, y = yvar, color = color, name = character, image = icon_url_path)}) %>%  
#    hc_add_series(type = 'scatter', data = if (input$tier_boxplot) { NULL} else {select(reactive_dataset(), x= xvar, y = yvar, color = color, name = character, image = icon_url_path)}) %>%  
#    hc_add_series(type = 'boxplot', data = if (input$tier_boxplot) {select(reactive_dataset(), x= xvar, y = yvar, group = group)} else {NULL}) %>% 
#    hc_legend(enabled = FALSE) %>%
#    hc_xAxis(title = list(text = input$xvar_input))%>%
#    hc_yAxis(title = list(text = input$yvar_input))%>%
#    hc_plotOptions(series = list(allowPointSelect= TRUE)) %>% 
#    hc_add_event_point(event = "click") %>% 
#    #hc_add_event_point(event = "mouseOut") %>% 
#    hc_add_series(data = if (is.null(input$main_datatable_rows_selected) | input$tier_boxplot) {NULL} 
#                  else {select(reactive_dataset()[input$main_datatable_rows_selected, ], x= xvar, y = yvar, color = color, name = character, image = icon_url_path)},  
#                  type = 'scatter', marker = list(radius = 30, lineColor = '#32CD32', lineWidth = 5)) %>% 
#    hc_tooltip(useHTML = TRUE, 
#               formatter= JS("function() {return (this.point.name + '<span style=\"color: this.point.color\"></br>y: <b>' + this.point.y + '</b> </br> x: <b>' +
# this.point.x + '</b></span></br><img src=\"'+ this.point.image + '\"width=\"48\" height=\"48\"/></br>');}")) %>% 
#    hc_add_theme(hc_theme_chalk()) 
#  

