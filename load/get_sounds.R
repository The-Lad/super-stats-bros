# Required libraries
library(rvest)
library(stringr)
library(dplyr)
source('data_constants.R')

site = "https://www.sounds-resource.com"
games = c('N64' = "/nintendo_64/supersmashbros/",
          'Melee' = "/gamecube/ssbm/",
          'Brawl' = "/wii/ssbb/",
          'Smash4' = "/wii_u/supersmashbrosforwiiu/",
          'Ultimate' = "/nintendo_switch/supersmashbrosultimate/")

old_sources = c('N64' ='https://www.sounds-resource.com/nintendo_64/supersmashbros/sound/2586/',
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


unzip('data/dont_commit/N64.zip', files = as.vector(char_list$n64_sounds[char_list$n64_sounds != ""]), exdir = 'www/audio/announcer/n64')
unzip('data/dont_commit/Melee.zip', files = as.vector(char_list$melee_sounds[char_list$melee_sounds != ""]), exdir = 'www/audio/announcer/melee')
unzip('data/dont_commit/Brawl.zip', files = as.vector(char_list$brawl_sounds[char_list$brawl_sounds != ""]), exdir = 'www/audio/announcer/brawl')
unzip('data/dont_commit/Smash4.zip', files = as.vector(char_list$smash4_sounds[char_list$smash4_sounds != ""]), exdir = 'www/audio/announcer/smash4')
unzip('data/dont_commit/Ultimate.zip', files = as.vector(char_list$ultimate_sounds[char_list$ultimate_sounds != ""]), exdir = 'www/audio/announcer/ultimate')

unzip('data/dont_commit/Melee.zip', files = melee_bonuses, exdir = 'www/audio/announcer/melee')


# DLC chars...



###
#mp3s <- httr::GET('https://www.sounds-resource.com/gamecube/ssbm/',
#          httr::add_headers('#content a'))

# mapped_names = c("%26" = ' & ',
#                  '.' = '',
#                  'Pit, but edgy' = 'Dark Pit',
#                  'Dank Samus' = 'Dark Samus',
#                  'Educated Mario' =  'Dr Mario',
#                  'Duck Hunt Duo' = 'Duck Hunt',
#                  '^Dedede$' =  'King Dedede',
#                  'King K. Rool'  = 'King K Rool',
#                  'King KRool'  = 'King K Rool',
#                  'Megaman' = 'Mega Man',
#                  'Mii Swordspider' = 'Mii Swordfighter',
#                  'M. Game & Watch' = 'Mr Game & Watch',
#                  'PAC-MAN' = 'Pac Man',
#                  'Pac-Man' = 'Pac Man',
#                  'PACMAN' = 'Pac Man',
#                  'Pok%C3%A9mon Trainer' = 'Pokemon Trainer',
#                  'é'  = 'e',
#                  'R.O.B.' = 'Rob',
#                  'ROB' = 'Rob',
#                  'Rosalina' = 'Rosalina & Luma')
# 