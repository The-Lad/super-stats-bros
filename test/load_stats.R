library(rvest)
library(dplyr)
library(stringr)

char_data_web = html_session('https://kuroganehammer.com/Ultimate')

#chars_img = html_nodes(char_data_web, css = '.rectangle')
#chars_links = html_nodes(char_data_web, css = 'a') %>% 
#  as.character() %>% 
#  str_subset('class="rectangle"|class="icon_nodata"')


# USAGE AND WINNING
char_data_web = tryCatch(char_data_web %>% jump_to('https://ssbworld.com/characters/usage/'),
                         error = function(e) {char_data_web %>% 
                             jump_to('https://ssbworld.com/characters/win-percentage/') %>% 
                             follow_link('view character usage')})

usage = char_data_web %>% html_nodes('.player-meta div')  %>% html_text() %>% str_remove_all(',| |\\(|\\)') %>% sapply(function(x) eval(parse(text = x)))
usage_chars=  char_data_web %>% html_nodes('#main-container a') %>% .[str_detect(.,  'character-profiles/')] %>% html_attr('href') %>% str_extract('(?!.*/).+$')
names(usage) = usage_chars %>% str_replace_all('-', ' ') %>% str_replace_all('and', '&') %>%  str_to_title()  

char_data_web = tryCatch(char_data_web %>% follow_link('View Character Win Percentage'),
                         error = function(e) {char_data_web %>% 
                             jump_to('https://ssbworld.com/characters/win-percentage/')})


winning = char_data_web %>% html_nodes('.player-meta div')%>% html_text() %>% str_remove_all('\\(|\\)')
winning_chars=  char_data_web %>% html_nodes('#main-container a') %>% .[str_detect(.,  'character-profiles/')] %>% html_attr('href') %>% str_extract('(?!.*/).+$')
names(winning) = winning_chars %>% str_replace_all('-', ' ') %>% str_replace_all('and', '&') %>%  str_to_title()  

missing_winnings = setdiff(usage_chars, winning_chars)
for (char in missing_winnings) {
  try({
    text = char_data_web %>% jump_to(paste0('https://ssbworld.com/characters/', char)) %>% html_nodes('.player-stat') %>% html_text() %>% 
      str_subset('-') %>%  str_extract('(?!.*:).+') %>% .[[1]]
    winning = c(winning, setNames(text, names(usage)[which(usage_chars == char)]))
  })
  
}

char_stats = left_join(char_stats, tibble::enframe(usage, "CHARACTER", "USAGE"))
char_stats$USAGE[char_stats$CHARACTER %in% c('Squirtle', 'Ivysaur', 'Charizard')] = usage['Pokemon Trainer']
char_stats$USAGE[char_stats$CHARACTER %in% c('Nana', 'Popo')] = usage['Ice Climbers']

char_stats = left_join(char_stats, tibble::enframe(winning, "CHARACTER", "WIN RATIO"))
char_stats$`WIN RATIO`[char_stats$CHARACTER %in% c('Squirtle', 'Ivysaur', 'Charizard')] = winning['Pokemon Trainer']
char_stats$`WIN RATIO`[char_stats$CHARACTER %in% c('Nana', 'Popo')] = winning['Ice Climbers']

char_stats$`GAMES WON` = as.numeric(str_remove(str_extract(char_stats$`WIN RATIO`, '[^\\s]+'), ',')) 
char_stats$`GAMES LOST` = as.numeric(str_remove(str_extract(char_stats$`WIN RATIO`, '[\\d-]+$'), ',')) 
char_stats$`WIN RATIO` = char_stats$`GAMES WON` / (char_stats$`GAMES LOST` + char_stats$`GAMES WON`)

# which(is.na(char_stats$`WIN RATIO`)) # less than 200 games,not shown

# Icons
#fighter_page = read_html('https://www.ssbwiki.com/Fighter')
#icons = fighter_page %>% html_nodes('td:nth-child(6) img') %>% html_attr('src') %>% str_replace('24px', '48px')
#files = paste0('pics/', str_extract(icons, '[^/]+$'))

icon_page = read_html('http://www.ssbwiki.com/Category:Head_icons_(SSBU)')
icons = icon_page %>% html_nodes('img') %>% html_attr('src') %>% str_subset('px')
files = paste0('pics/', str_extract(icons, '[^/]+$'))

if (!dir.exists('pics')) dir.create('pics')
if (any(!file.exists(files))) {
  sapply(paste0('http://www.ssbwiki.com/', icons[!file.exists(files)]), function(x) download_html(x, paste0('pics/', str_extract(x, '[^/]+$'))))
}

names(files) = str_remove_all(files, 'pics/120px-|HeadSSBUWebsite.png') %>% str_replace_all(mapped_names) %>% str_remove_all(' |-')
names(files)[names(files) == 'ROB'] = 'Rob'
icons = paste0('https://www.ssbwiki.com', icons)
names(icons) = names(files)
files = c(files, setNames( rep(files[names(files) == 'IceClimbers'], 2), c('Nana', 'Popo')))
icons = c(icons,  setNames( rep(icons[names(icons) == 'IceClimbers'], 2), c('Nana', 'Popo')))


proper_names = char_stats$CHARACTER
char_stats = left_join(char_stats %>% mutate(CHARACTER = str_remove_all(CHARACTER, " ")), tibble::enframe(files, "CHARACTER", "ICON PATH"))
char_stats = left_join(char_stats, tibble::enframe(icons, "CHARACTER", "ICON URL PATH"))

char_stats$CHARACTER = proper_names

char_colors = readxl::read_excel('data/smash_colors.xlsx', sheet = 'Characters') %>% 
  select(-Fighter, -`CSS code`)
#char_stats = char_stat

if (!dir.exists('data')) dir.create('data')
saveRDS(char_stats, 'data/char_stats.rds')
