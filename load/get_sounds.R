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

if (!dir.exists('data/dont_commit')) dir.create('data/dont_commit')

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

if (!dir.exists('www/')) dir.create('www/')
if (!dir.exists('www/audio')) dir.create('www/audio')
if (!dir.exists('www/audio/announcer')) dir.create('www/audio/announcer')

unzip('data/dont_commit/N64.zip', files = as.vector(char_list$n64_sounds[char_list$n64_sounds != ""]), exdir = 'www/audio/announcer/n64')
unzip('data/dont_commit/Melee.zip', files = as.vector(char_list$melee_sounds[char_list$melee_sounds != ""]), exdir = 'www/audio/announcer/melee')
unzip('data/dont_commit/Brawl.zip', files = as.vector(char_list$brawl_sounds[char_list$brawl_sounds != ""]), exdir = 'www/audio/announcer/brawl')
unzip('data/dont_commit/Smash4.zip', files = as.vector(char_list$smash4_sounds[char_list$smash4_sounds != ""]), exdir = 'www/audio/announcer/smash4')
unzip('data/dont_commit/Ultimate.zip', files = as.vector(char_list$ultimate_sounds[char_list$ultimate_sounds != ""]), exdir = 'www/audio/announcer/ultimate')

unzip('data/dont_commit/Melee.zip', files = melee_bonuses, exdir = 'www/audio/announcer/melee')

file.remove('data/dont_commit/N64.zip')
file.remove('data/dont_commit/Melee.zip')
file.remove('data/dont_commit/Brawl.zip')
file.remove('data/dont_commit/Smash4.zip')
file.remove('data/dont_commit/Ultimate.zip')

# This is just more intelligent
require(sound)
saveSample(appendSample(paste0('audio/announcer/melee/', melee_bonuses['READY']), 
                        as.Sample(rep(0, 500), rate = 1000), 
                        paste0('audio/announcer/melee/', melee_bonuses['GO'])),
           'www/audio/easter/readygo.wav', overwrite = TRUE)

# For the egg
piano = FALSE
if (piano) {
  if (!dir.exists('www/audio/easter')) dir.create('www/audio/easter')
  try({
    download_site = 'http://www.mediafire.com/file/zd1mqtazulgv28a/mp3_Notes.rar/file'
    piano_file = read_html(download_site) %>% 
      html_node('.input') %>% html_attr('href')
    tf = tempfile()
    download.file(piano_file, tf, mode="wb") #'data/dont_commit/mp3 Notes.rar')
    z7path = shQuote('C:\\Program Files\\7-Zip\\7z')
    cmd = paste(z7path, ' e ', paste('"', tf, '"',sep = ''), ' -ir!*.* -o', '"', paste0(getwd(), '/www/audio/easter'), '"', sep='')
    system(cmd)
    unlink(t)
  })
}


# keys = read_html('https://github.com/fuhton/piano-mp3/tree/master/piano-mp3') %>% html_nodes('a') %>%
#   html_attr('href') %>%  str_subset('.{2,3}\\.mp3') %>% str_extract("[^/]+[/]?$")
# for (key in keys) {
#   download.file(paste0('https://raw.githubusercontent.com/fuhton/piano-mp3/master/piano-mp3/', key), destfile = paste0('www/audio/easter/', key))
# }

#keys = httr::GET('https://raw.githubusercontent.com/fuhton/piano-mp3/master/package.json',
#          httr::add_headers('content-type' = 'application/json'))
#keys_json = jsonlite::fromJSON(httr::content(keys, 'text')) 
#keys_json$repository$url
# git2r::clone('https://github.com/fuhton/piano-mp3.git')
#'https://github.com/fuhton/piano-mp3/tree/master/piano-mp3'