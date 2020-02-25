# Tournament wins (sketchy but fun)
# library(rvest)
# library(dplyr)
# library(stringr)

# Includes secondaries and runner ups
major_tournament_chars <- read_html('https://liquipedia.net/smash/Major_Tournaments/Ultimate') %>% html_nodes('.heads-padding-right img')  %>% html_attr('alt') %>%
  str_replace_all(mapped_names) %>% 
  table() %>% as_tibble(n = 'tournament_win_freq')

# Includes secondaries, as well as both Fall and Spring PGRs
top_player_chars =  read_html('https://liquipedia.net/smash/PGRU') %>% html_nodes('td~ td+ td img')%>% html_attr('alt') %>%
  str_replace_all(mapped_names) %>% 
  table() %>% as_tibble(n = 'top_player_freq')

