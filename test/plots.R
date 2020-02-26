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

