library(rvest)
site = "https://www.sounds-resource.com"
games = c('64' = "/nintendo_64/supersmashbros/",
          'Melee' = "/gamecube/ssbm/",
          'Brawl' = "/wii/ssbb/",
          'Smash4' = "/wii_u/supersmashbrosforwiiu/",
          'Ultimate' = "/nintendo_switch/supersmashbrosultimate/")

old_sources = c('64' ='https://www.sounds-resource.com/nintendo_64/supersmashbros/sound/2586/',
                'Melee' = 'https://www.sounds-resource.com/gamecube/ssbm/sound/439/',
                'Brawl' = 'https://www.sounds-resource.com/wii/ssbb/sound/537/',
                'Smash4'= 'https://www.sounds-resource.com/wii_u/supersmashbrosforwiiu/sound/4384/',
                'Ultimate'  = 'https://www.sounds-resource.com/nintendo_switch/supersmashbrosultimate/sound/16070/')

data <- list()
for (game in names(games)) {
  if (!file.exists(paste0('data/dont_commit/', game,'.zip'))){
    tryCatch({
      narrator <- read_html(old_sources[game])
    },  error = function(e) {
      # Not guaranteed to work! NEEDS TESTING
      narrator <-  read_html(paste0(site, games[game])) %>% 
        html_nodes('a') %>% 
        .[str_which(html_text(.), '[N|n]arrator|[A|a]nnouncer|[V|v]oices')] %>% # find Narrator
        html_attr('href') %>% 
        paste0(site, .) %>% 
        read_html()
    }
    )
    #temp <- tempfile()
    narrator %>% 
      html_nodes('#content a') %>%
      .[str_which(html_text(.), '[D|d]ownload')] %>% 
      html_attr('href') %>% 
      paste0(site,.) %>% 
      download.file(destfile = paste0('data/dont_commit/', game,'.zip'), mode = 'wb')
    #temp
    
  }
}

unzip('data/dont_commit/64.zip', list = TRUE)
###
#mp3s <- httr::GET('https://www.sounds-resource.com/gamecube/ssbm/',
#          httr::add_headers('#content a'))

