library(rvest)

tryCatch(
  {narrator <- read_html('https://www.sounds-resource.com/gamecube/ssbm/sound/439/')},
    error = function(e) {
      narrator <-  read_html('https://www.sounds-resource.com/gamecube/ssbm/') %>% 
        html_nodes('a') %>% 
        .[str_which(html_text(.), '[N|n]arrator')] %>% # find Narrator
        html_attr('href') %>% 
        paste0('https://www.sounds-resource.com',.) %>% 
        read_html()
    }
)


download = narrator %>% 
  html_nodes('#content a') %>%
  .[str_which(html_text(.), '[D|d]ownload')] %>% 
  html_attr('href') %>% 
  paste0('https://www.sounds-resource.com',.) %>% 
  download.file(destfile = 'data/dont_commit/ssbm.zip')


###
#mp3s <- httr::GET('https://www.sounds-resource.com/gamecube/ssbm/',
#          httr::add_headers('#content a'))

