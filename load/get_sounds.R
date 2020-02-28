library(rvest)
site = "https://www.sounds-resource.com/"
games = c('64' = "nintendo_64/supersmashbros/",
          'Melee' = "gamecube/ssbm/",
          'Brawl' = "wii/ssbb/",
          'Smash 4' = "wii_u/supersmashbrosforwiiu/",
          'Ultimate' = "nintendo_switch/supersmashbrosultimate/")

old_sources = c('64' ='https://www.sounds-resource.com/nintendo_64/supersmashbros/sound/2586/',
                'Melee' = 'https://www.sounds-resource.com/gamecube/ssbm/sound/439/',
                'Brawl' = 'https://www.sounds-resource.com/wii/ssbb/sound/537/',
                'Smash 4'= 'https://www.sounds-resource.com/wii_u/supersmashbrosforwiiu/sound/4384/',
                'Ultimate'  = 'https://www.sounds-resource.com/nintendo_switch/supersmashbrosultimate/sound/16070/')
for (game in games) {
  
  tryCatch(
    {narrator <- read_html('https://www.sounds-resource.com/gamecube/ssbm/sound/439/')},
    error = function(e) {
      narrator <-  read_html('https://www.sounds-resource.com/gamecube/ssbm/') %>% 
        html_nodes('a') %>% 
        .[str_which(html_text(.), '[N|n]arrator|[V|v]oice|[A|a]nnouncer')] %>% # find Narrator
        html_attr('href') %>% 
        paste0('https://www.sounds-resource.com',.) %>% 
        read_html()
    }
  )
  narrator %>% 
    html_nodes('#content a') %>%
    .[str_which(html_text(.), '[D|d]ownload')] %>% 
    html_attr('href') %>% 
    paste0('https://www.sounds-resource.com',.) %>% 
    download.file(destfile = paste0('data/dont_commit/', ,'.zip'))
}

###
#mp3s <- httr::GET('https://www.sounds-resource.com/gamecube/ssbm/',
#          httr::add_headers('#content a'))

