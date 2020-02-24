hchart(char_stats, hcaes(y = `MAX AIR SPEED VALUE`, x = `MAX FALL SPEED`, group = CHARACTER), color = '#000000', type = 'scatter') %>% 
  hc_tooltip(useHTML = TRUE, 
             pointFormat = '<span style="color:{point.color}">Fall speed: </span>: {point.y:,.0f}<br/>',
             headerFormat = '<span style="font-size: 10px">{series.name}</span><br/>') %>% 
  hc_legend(enabled = FALSE)



hchart(char_stats, hcaes(y = `MAX AIR SPEED VALUE`, x = `MAX FALL SPEED`, name = CHARACTER, group = `ICON URL PATH`), color = '#000000', type = 'scatter') %>% 
  hc_tooltip(useHTML = TRUE, 
             #pointFormat = '<span style="color:{point.color}">Fall speed: </span>: {point.y:,.0f}<br/>',
             #headerFormat = '<span style="font-size: 10px">{series.name}</span><br/>',
             formatter= JS("function() {          
             var img = '<img src = \"' + this.series.name +'\" width=\"48\" height=\"48\"/>'
             return img;
           }")) %>% 
  hc_legend(enabled = FALSE)

url = read_html('https://www.ssbwiki.com/Category:Head_icons_(SSBU)') %>% html_nodes('.gallerybox:nth-child(4) img')

hchart(char_stats, hcaes(y = `MAX AIR SPEED VALUE`, x = `MAX FALL SPEED`, group = CHARACTER, image = `ICON PATH`), color = '#000000', type = 'scatter') %>% 
  hc_tooltip(useHTML = TRUE, 
             #pointFormat = '<span style="color:{point.color}">Fall speed: </span>: {point.y:,.0f}<br/>',
             #headerFormat = '<span style="font-size: 10px">{series.name}</span><br/>',
             formatter= JS("function() {                        
        return '<img src = \"' + 'https://www.ssbwiki.com/images/thumb/2/27/BayonettaHeadSSBUWebsite.png/120px-BayonettaHeadSSBUWebsite.png' +'\"/>';
           }")) %>% 
  hc_legend(enabled = FALSE)

hchart(char_stats, hcaes(y = `MAX AIR SPEED VALUE`, x = `MAX FALL SPEED`, group = CHARACTER, image = `ICON PATH`), color = '#000000', type = 'scatter') %>% 
  hc_tooltip(useHTML = TRUE, 
             #pointFormat = '<span style="color:{point.color}">Fall speed: </span>: {point.y:,.0f}<br/>',
             pointFormat = tooltip_chart('ICON PATH')) %>% 
  hc_legend(enabled = FALSE)




tb <- shiny::tagList(
  tags$img(
    src = paste0(char_stats$`ICON URL PATH`[1], "{point.image}"),
    width = "48px", height = "48px")
) %>% 
  as.character() %>% 
  str_c(tooltip_table(x = 'Name:', y= '$ {series.name}',  cellspacing="0", 
                      cellpadding="0", 
                      style = "border:none; border-collapse: collapse;"), .)


char_stats2 = char_stats %>% 
  mutate(marker =  purrr::map(`ICON URL PATH`, ~ list(symbol = sprintf("url(%s)", .x))))

hchart(char_stats2, hcaes(y = `MAX AIR SPEED VALUE`, x = `MAX FALL SPEED`, group = CHARACTER, name = CHARACTER),  type = 'point', marker = list(fillOpacity = 0.05, lineWidth = NULL)) %>% 
  hc_tooltip(useHTML = TRUE, 
             pointFormat = tb,
             borderRadius = 0,
             borderWidth = 5,
             headerFormat = "",
             footerFormat = "") %>% 
  hc_legend(enabled = FALSE)

highchart() %>% 
  hc_add_series(char_stats2, 'point', hcaes(y = `MAX AIR SPEED VALUE`, x = `MAX FALL SPEED`, group = CHARACTER, name = CHARACTER),
                marker = list(symbol = '<img src=\"ssbwiki.com/images/thumb/9/95/JigglypuffHeadSSBU.png/48px-JigglypuffHeadSSBU.png\"/>'))

#char_stats$`ICON PATH` = paste0('C:/Users/nick.m/Documents/Work/Shiny contest/super-stats-bros/', char_stats$`ICON PATH`)